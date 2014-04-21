/* lexical grammar */
%{
var reserved_words ={ PI: 'PI', E : 'E', VAR: 'VAR', CONST: 'CONST', ODD: 'ODD' ,IF : 'IF', THEN : 'THEN', ELSE : 'ELSE',WHILE : 'WHILE', PROCEDURE : 'PROCEDURE', BEGIN: 'BEGIN', END: 'END', CALL: 'CALL'}

function idORrw(x) {
  return (x.toUpperCase() in reserved_words)? x.toUpperCase() : 'ID'
}

%}
%%

\s+|\#.*                         /* skip whitespace and comments */
\b\d+("."\d*)?([eE][-+]?\d+)?\b  return 'NUMBER'
\b[A-Za-z_]\w*\b                 return idORrw(yytext)
[<>=!][=]|[<>]                   return 'COMPARISON'
[-*/+^!%=();]                    return yytext;
"."                              return 'DOT'
","                              return 'COMMA'
.                                return 'INVALID'
<<EOF>>                          return 'EOF'

