/* description: Parses end executes mathematical expressions. */

%{
  var symbol_tables = [{ nombre:"GLOBAL", padre: null, contenido: {}}];
  var ambito = 0;
  var symbol_table = symbol_tables[ambito];
  
  function getambito(){
    return ambito;
  }
 /* 
  function subir_ambito(){
    ambito--;
    symbol_table = symbol_tables[ambito];
  }
  */
  function crear_ambito(ID){
    ambito++;
    symbol_tables.push({ nombre: ID, padre:symbol_table.nombre, contenido:{}});
    symbol_table = symbol_tables[ambito];	
    return symbol_table;
  }
  
  function encontrar_id(ID){
    var id;
    var ambito_actual = ambito;
    
    do {
      id = symbol_tables[ambito_actual].contenido[ID];
      ambito_actual--;
    } while (ambito_actual >= 0 && !id)
    
    ambito_actual++; 
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
	  var obj = symbol_tables;
	  
	  symbol_tables = [{ nombre:"GLOBAL", padre: null, contenido: {}}];
	  ambito = 0;
	  symbol_table = symbol_tables[ambito];
	  
          return [$$, obj];
        }
    ;


block
     : cont var procedure s+
          { $$ = [];
            if ($1) $$.push($1);
            if ($2) $$.push($2);
            if ($3) $$.push($3);
            $$.push($4);
            console.log($$);
          }
     ;


procedure
     : PROCEDURE nombre_completo 'BEGIN' block 'END' ";" procedure
         { $$ = [{
                type: 'PROCEDURE',
                id: $2.id,
                parameters: $2.param,
                block: $4
                }];

		if ($7) { $$.concat($7);};
         }
     |/*vacio*/
     ;

nombre_completo
     : ID "(" parameters ")"
	{	
	    $$ = {
		 id: $ID,
		 param: $parameters
	    };
	    
	    if ($3){
	      symbol_table.contenido[$ID] = { type: 'Procedure', nombre: $ID, n_parametros: $3.length }; 
	      crear_ambito($ID);
	      for (var i=0; i < $3.length; i++) {
		symbol_table.contenido[$3[i].value] = {type: 'PAR'};
	      }
	    }

	    
	    else{
	      symbol_table.contenido[$ID] = { type: 'Procedure', nombre: $ID, n_parametros: 0 }; 
	      crear_ambito($ID);
	    }
	    
	
	}
     ;


parameters
     :  param_ID otro_parameter  
         { $$ = [{
		type: 'PAR',
                value: $1
                }];

           if ($2) { $$.concat($2);};
         }
     |/*vacio*/
     ;
     
// parameters_call
//      :  s
//      ;
//  Mirar para cada argumento en el call si está en la symbol_table del ámbito actual o superior (encontrar_id)
//  

otro_parameter
     : COMMA param_ID otro_parameter
         { $$ = [{
		type: 'PAR',
                value: $2
                }];

                if ($3) { $$.concat($3);};
         }
     |/*vacio*/
     ;

param_ID
    :ID
      {	
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
	//if(symbol_table.contenido[$ID])
	//  throw new Error("Variable: " + $ID + " ya está definida.");
	symbol_table.contenido[$ID] = {type: 'VAR'};
	
	$$ = $ID;
	
      }
    ;
   
 cont
    : CONST cont_ID cont_otra ";"
    |/*vacio*/ 
     ;
    
 cont_otra
    : COMMA cont_ID cont_otra 
    | /*vacio*/
    ;

cont_ID
    : ID "=" NUMBER
      {
	if(symbol_table.contenido[$ID])
	  throw new Error("Constante: " + $ID + " ya está definida.");
	
	symbol_table.contenido[$ID] = {type: 'CONST', name: $ID, value: $NUMBER  };
	
	$$ = [];
	$$.push($ID);
	$$.push($NUMBER);
	
      }
    ;    
    
s
    :  ID '=' e ';'
         {
	   var result = encontrar_id($ID);
           //var s = info[1];
           //info = info[0];

           if (result[0] && result[0].type === 'VAR') {
               $$ = {
	      type: "=",
	      left: $1,
	      right: $3	    
	      };
           }
           else if (result[0] && result[0].type === 'PAR') {
              $$ = {
	      type: "=",
	      left: $1,
	      right: $3	    
	      };
           }
           else if (result[0] && result[0].type === 'FUNC') {
              throw new Error("Símbolo "+$ID+" referencia a funcion");
           }
           else if (result[0] && result[0].type === 'CONST') {
              throw new Error("Símbolo "+$ID+" referencia a constante");
           }
           else {
              throw new Error("Símbolo "+$ID+" referencia no declarada");
           }
        
	 }
    | CALL ID "(" parameters ")" ";"
      {
	      console.log("antes if");        
	      var par = $4;
	      var result = encontrar_id($ID);
	      if (result[0] && result[0].type === "Procedure") { //comprobamos que procedure definido y el tipo
		console.log("if 1");
		
		if(!par && !result[0].n_parametros){
		   $$ = {
		      type: 'CALL',
		      value: $2,
		      parameters: "no parametros"
		   }; /* object */
		} /* if */
		
		else {
		  if (!result[0].n_parametros || !par) {
		    throw new Error("Llamada a "+$ID+" con número de parámetros erróneo");
		  }
		    
		  else {
		    console.log("length: " + $4.length);
		    console.log("n_par: " + result[0].n_parametros);
		    if ($4.length === result[0].n_parametros) {
// 		      
		      for (var i = 0; i < $4.length; i++) {
			var temp = encontrar_id(par[i].value); // Era aquí el error XD
			if(!temp) 
			  throw new Error("Símbolo "+temp.id.value+" referencia no declarada");
		      } /* for */
		      
		      $$ = {
			  type: 'CALL',
			  value: $2,
			  parameters: $4
		      }; /* object */
		      
		    } /* if */
		    else 
		      throw new Error("Llamada a "+$ID+" con número de parámetros erróneo"); 
		   } /* else */
		} /* else */
		
	        //return $$;

	      } /* if */
	      
	      else 
		  throw new Error("Símbolo "+$ID+" referencia no declarada");
         } /* END */
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

