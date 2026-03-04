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
%token NUMBER
%%

expressions
    : expression EOF
        { return $expression; }
    ;

expression
    : expression OP term
        { $$ = operate($OP, $expression, $term); }
    | term
        { $$ = $term; }
    ;

term
    : NUMBER
        { $$ = Number(yytext); }
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
