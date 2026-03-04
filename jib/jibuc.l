%{
#include "jibuc.tab.h"
#include <string.h>
%}

%option caseless
%option noyywrap

%%

"BEGINNING"     { return BEGINNING; }
"END"           { return END; }
"BODY"          { return BODY; }
"MOVE"          { return MOVE; }
"TO"            { return TO; }
"ADD"           { return ADD; }
"INPUT"         { return INPUT; }
"PRINT"         { return PRINT; }

[xX]+           { yylval.str = strdup(yytext); return SIZE_STRING; }

[a-zA-Z][a-zA-Z0-9\-]* { yylval.str = strdup(yytext); return IDENTIFIER; }

[0-9]+          { yylval.str = strdup(yytext); return INTEGER; }

\"[^\"]*\"      { yylval.str = strdup(yytext); return STRING_LITERAL; }

"."             { return DOT; }
";"             { return SEMICOLON; }

[ \t\r\n]+      { /* skip whitespace */ }

.               { fprintf(stderr, "Error: unexpected character '%s'\n", yytext); }

%%
