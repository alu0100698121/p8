/* description: Parses end executes mathematical expressions. */

%{
  var symbol_table = [{ nombre:"", padre: null, contenido: {}}];
  var ambito = 0;
  var symbol_table = symbol_table[ambito];
  
  function getambito(){
    return ambito;
  }
  
  function subir_ambito(){
    ambito--;
    symbol_table = symbol_table[ambito];
  }
  
  function crear_ambito(ID){
    ambito++;
    symbol_table[contenido].symbol_table = symbol_table[ambito] = { nombre: ID, padre:symbol_table, contenido:{}};
    symbol_table = symbol_table[ambito];	
  }
  
  function encontrar_id(ID){
    var id;
    var ambito_actual = ambito;
    
    while (ambito_actual > 0 && !id){
      id = symbol_table[ambito_actual].contenido[ID];
      ambito_actual--;
    }
    
    ambito_actual++; //no se por que coño hace esto.
    return [id,ambito_actual];
  }
    

%}

%token NUMBER ID EOF
/* operator associations and precedence */

%right ELSE THEN
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS


%start prog

%% /* language grammar */
prog
    : block DOT
        { 
          $$ = $1; 
          console.log($$);
          return [$$, symbol_table];
        }
    ;


block
     : cont var procedure s
          { $$ = [];
            if ($1) $$.push($1);
            if ($2) $$.push($2);
            if ($3) $$.push($3);
            $$.push($4);
            console.log($$);
          }
     ;


procedure
     : PROCEDURE procedure_ID "(" parameters ")" 'BEGIN' block 'END' ";" procedure
         { $$ = [{
                type: 'PROCEDURE',
                id: $2,
                parameters: $4,
                block: $7
                }];

		if ($10) { $$.concat($10);};
         }
     |/*vacio*/
     ;


parameters
     :  param_ID otro_parameter  
         { $$ = [{
                value: $1
                }];

           if ($2) { $$.concat($2);};
         }
     |/*vacio*/
     ;

otro_parameter
     : COMMA param_ID otro_parameter
         { $$ = [{
                value: $2
                }];

                if ($3) { $$.concat($3);};
         }
     |/*vacio*/
     ;

param_ID
    :e
      {
	if(symbol_table.contenido[$ID]
	  throw new Error("Nombre de param " + $e + " repetido");
	symbol_table.contenido[$e] = {type: 'Param'};
	
	$$ = $e;
      }
    ;  
     
procedure_ID
    : ID
      {
	if(symbol_table.contenido[$ID]
	  throw new Error("Procedure " + $ID + " ya ha sido definido");
	symbol_table.contenido[$ID] = { type: 'Procedure', nombre: $ID }; 
	crear_ambito($ID);
	
	$$ = $ID;
	
      }
   ;

    

var
    : VAR var_ID var_otra ";"
	{$$ = [{
	      type: 'VAR',
	      right: $2	    
	      }];
	      
	      if($3) { $$.concat($3); };
	 }
     |/*vacio*/ 
    ;
    
var_otra
    : COMMA var_ID var_otra
	{$$ = [{
	      type: 'VAR',
	      right: $2	    
	      }];
	      
	      if ($3) { $$.concat($3);};
	 }
    |/*vacio*/
    ;  
    
var_ID
    : ID
      {
	if(symbol_table.contenido[$ID]
	  throw new Error("Variable: " + $ID + " ya está definida.");
	
	symbol_table.contenido[$ID] = {type: 'VAR'};
	
	$$ = $ID;
	
      }
    ;
    
 cont
    : CONST cont_ID cont_otra ";"
	{$$ = [{
	      type: 'CONST',
	      left: $2[0],
	      right: $2[1]    
	      }];
	      
	      if($5){ $$.concat($5);};
	}
    |/*vacio*/ 
     ;
    
 cont_otra
    : COMMA cont_ID cont_otra
	{$$ = [{
	      type: 'CONST',
	      left: $2[0],
	      right: $2[1]     
	      }];
	      
	      if($5){ $$.concat($5);};
	 }
 
    | /*vacio*/
    ;

cont_ID
    : ID "=" NUMBER
      {
	if(symbol_table.contenido[$ID]
	  throw new Error("Constante: " + $ID + " ya está definida.");
	
	symbol_table.contenido[$ID] = {type: 'Const', name: $ID value: $NUMBER  };
	
	$$ = [];
	$$.push($ID);
	$$.push($NUMBER);
	
      }
    ;    
    
s
    :  ID '=' e ';'
         {$$ = {
	      type: "=",
	      left: $1,
	      right: $3	    
	      };
	 }
    | CALL ID "(" parameters ")" ";"
         {$$ = {
              type: 'CALL',
              value: $2,
              parameters: $4
              };
         }
    | IF c THEN s ELSE s 
	 {$$ = {
		type:'IFELSE',
		condition: $2,
		true_statement: $4,
		else_statement: $6
		};
	 }
	  
    | IF c THEN s
	{$$ = {
	       type:'IF',
	       condition: $2,
	       true_statement: $4
	      };
	}
	 
    ;

//     factor = NUMBER
//        / ID
//        / LEFTPAR t:exp RIGHTPAR   { return t; }
    
    
// cond   = c:factor op:COMPARISON? e:exp? { return {type: op, left: c, right: e}; }
c  //comparison
    : e COMPARISON e
	{ $$ = {
		type: $2,
		left: $1,
		right: $3
		};
	}
    
    | ODD e
	{ $$ = {
		type: "ODD",
		right: $2
		};
	}
    ;
    
e
    : e '+' e
        {$$ = {
	      type: "+",
	      left: $1,
	      right: $3	    
	      };
        }
    | e '-' e
        {$$ = {
	      type: "-",
	      left: $1,
	      right: $3	    
	      };
        }
    | e '*' e
       {$$ = {
	      type: "*",
	      left: $1,
	      right: $3	    
	      };
        }
    | e '/' e
        {
          if ($3 == 0) throw new Error("Division by zero, error!");
         $$ = {
	      type: "/",
	      left: $1,
	      right: $3	    
	      };
        }

    | '-' e %prec UMINUS
          {$$ = {
	      type: "UMINUS",
	      value: $2,   
	      };
        }
    | '(' e ')'
        {$$ = {
	      type: "()",
	      value: $2,   
	      };
        }
    | NUMBER
        {$$ = Number(yytext);}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    | ID
        { $$ = symbol_table[yytext] || 0; }
        
    ;

