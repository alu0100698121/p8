/* description: Parses end executes mathematical expressions. */

%{
var symbol_table = {};

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

//expressions
//    : s  
//        { $$ = (typeof $1 === 'undefined')? [] : [ $1 ]; }
//    | expressions ';' s
//        { $$ = $1;
//          if ($3) $$.push($3); 
//          console.log($$);
//        }
//    ;

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
     : PROCEDURE ID "(" parameters ")" 'BEGIN' block 'END' ";" procedure
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
     : e otro_parameter  
         { $$ = [{
                value: $1
                }];

           if ($2) { $$.concat($2);};
         }
     |/*vacio*/
     ;

otro_parameter
     : COMMA e otro_parameter
         { $$ = [{
                value: $2
                }];

                if ($3) { $$.concat($3);};
         }
     |/*vacio*/
     ;

// bloques_const = i:constante j:otracostante* ";"_ {return [i].concat(j);}
// constante = _"const" i:ID "=" n:NUMBER {return {type: "const", left:i, right:n};}
// otracostante = "," _ i:ID "=" n:NUMBER {return {type: "const", left:i, right:n};}
    

var
    : VAR ID var_otra ";"
	{$$ = [{
	      type: 'VAR',
	      right: $2	    
	      }];
	      
	      if($3) { $$.concat($3); };
	 }
     |/*vacio*/ 
    ;
    
var_otra
    : COMMA ID var_otra
	{$$ = [{
	      type: 'VAR',
	      right: $2	    
	      }];
	      
	      if ($3) { $$.concat($3);};
	 }
    |/*vacio*/
    ;  
    
 cont
    : CONST ID "=" NUMBER cont_otra ";"
	{$$ = [{
	      type: 'CONST',
	      left: $2,
	      right: $4     
	      }];
	      
	      if($5){ $$.concat($5);};
	}
    |/*vacio*/ 
     ;
    
 cont_otra
    : COMMA ID "=" NUMBER cont_otra
	{$$ = [{
	      type: 'CONST',
	      left: $2,
	      right: $4     
	      }];
	      
	      if($5){ $$.concat($5);};
	 }
 
    | /*vacio*/
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

