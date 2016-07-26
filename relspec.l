%{
	#include "relspec.tab.h"
%}

letter [a-zA-Z]
digit [0-9]
%%
[ \t] ;
[ \n] { yylineno = yylineno + 1;}
int return INTEGER;
float return FLOAT;
void return VOID;
while return WHILE;
if return IF;
else return ELSE;
re return RE;
try return TRY;
parr return PARR;
return return RETURN;
^"#include ".+ ;
{digit}+ {yylval.i = atoi(yytext);return INTEGER_NUMBER;}
{digit}+"."{digit}+ {yylval.f = atof(yytext);return FLOAT_NUMBER;}
{letter}({letter}|{digit}|_)* return IDENTIFIER;
"<=" return LE;
">=" return GE;
"==" return EQ;
"!=" return NE;
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;
. return yytext[0];
%%
