%{
#include <stdio.h>
%}

%%

"//"[^\n]*    { printf("COMMENT: %s\n", yytext); }
.|\n          { /* pass through everything else */ }

%%

int main(void) {
    yylex();
    return 0;
}

int yywrap(void) {
    return 1;
}
