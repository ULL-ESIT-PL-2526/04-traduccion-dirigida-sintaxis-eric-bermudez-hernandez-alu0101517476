/* Lexer */
%lex
%%
\s+                                     { /* skip whitespace */ }
\/\/.*                                  { /* skip single line comments */ }
[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?\b   { return 'NUMBER'; }

/* Nuevos operadores clasificados por prioridad */
"**"                                    { return 'OPOW'; }
[*/]                                    { return 'OPMU'; }
[-+]                                    { return 'OPAD'; }

/* Paréntesis */
"("                                     { return '('; }
")"                                     { return ')'; }

<<EOF>>                                 { return 'EOF'; }
.                                       { return 'INVALID'; }
/lex

/* Parser */
%start expressions
%%

expressions
    : E EOF
        { return $1; }
    ;

/* Sumas y Restas (Asociatividad Izquierda) */
E
    : E OPAD T
        { $$ = operate($OPAD, $E, $T); }
    | T
        { $$ = $T; }
    ;

/* Multiplicaciones y Divisiones (Asociatividad Izquierda) */
T
    : T OPMU R
        { $$ = operate($OPMU, $T, $R); }
    | R
        { $$ = $R; }
    ;

/* Potencias (Asociatividad Derecha) */
R
    : F OPOW R
        { $$ = operate($OPOW, $F, $R); }
    | F
        { $$ = $F; }
    ;

/* Números y Paréntesis */
F
    : NUMBER
        { $$ = Number(yytext); }
    | '(' E ')'
        { $$ = $E; }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}
