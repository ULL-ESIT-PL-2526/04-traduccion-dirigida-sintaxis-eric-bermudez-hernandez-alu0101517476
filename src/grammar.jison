/* Lexer */
%lex
%%

\s+                                   { /* skip whitespace */ }
\/\/.*                                { /* skip single line comments */ }
\/\*[^]*?\*\/                          { /* skip multi-line comments */ }
[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?\b { return 'NUMBER'; }
"**"                                  { return '**'; }
[-+*/]                                { return yytext; }
<<EOF>>                               { return 'EOF'; }
.                                     { return 'INVALID'; }

/lex

/* Parser */

/* Declaramos la precedencia de menor a mayor prioridad */
%left '+' '-'
%left '*' '/'
%right '**'

%start expressions
%%

expressions
    : expression EOF
        { return $1; }
    ;

expression
    : expression '+' expression
        { $$ = $1 + $3; }
    | expression '-' expression
        { $$ = $1 - $3; }
    | expression '*' expression
        { $$ = $1 * $3; }
    | expression '/' expression
        { $$ = $1 / $3; }
    | expression '**' expression
        { $$ = Math.pow($1, $3); }
    | NUMBER
        { $$ = Number(yytext); }
    ;