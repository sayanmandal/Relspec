//using namespace std;
%union	//token return type
{
  float f;
  int i;
}

%token INTEGER FLOAT IDENTIFIER WHILE IF ELSE RE TRY PARR VOID RETURN
%token <f> FLOAT_NUMBER
%token <i> INTEGER_NUMBER
%right '='
%right THEN ELSE
%left LE GE EQ NE '<' '>'
%%

Program			:	DeclarationList ;
DeclarationList		:	DeclarationList Declaration | Declaration ;
Declaration		:	VarDeclaration | FunDeclaration ;
VarDeclaration		:	TypeSpecifier IDENTIFIER ;
TypeSpecifier		:	INTEGER | FLOAT | VOID ;
FunDeclaration		:	TypeSpecifier IDENTIFIER '(' Parameters ')' CompoundStatement ;
Parameters	   	:	ParameterList | VOID | ;
ParameterList		:	ParameterList ',' Parameter | Parameter ;
Parameter		:	TypeSpecifier IDENTIFIER ;
CompoundStatement	:	'{' LocalDeclaration StatementList '}' ;
LocalDeclaration	:	LocalDeclaration VarDeclaration | ;
StatementList		:	StatementList Statement | ;
Statement		:	ExpressionStatement | IterationStatement | SelectionStatement | CompoundStatement | JumpStatement | RepetitionStatement | ParallelStatement | TryStatement;
ExpressionStatement	:	'[' INTEGER_NUMBER ']' Expression ';';
IterationStatement	:	WHILE '[' INTEGER_NUMBER ',' INTEGER_NUMBER']' '(' Expression ')' Statement;
SelectionStatement	: 	IF '[' INTEGER_NUMBER ',' FLOAT_NUMBER ']' '(' Expression ')' Statement	ElsePart;
ElsePart		:	ELSE Statement|	%prec THEN;
RepetitionStatement	:	RE '[' INTEGER_NUMBER ',' INTEGER_NUMBER ']' Expression ';';
ParallelStatement	:	PARR '[' INTEGER_NUMBER ',' INTEGER_NUMBER ',' INTEGER_NUMBER ']' Expression ';';
TryStatement		:	TRY '[' INTEGER_NUMBER ','INTEGER_NUMBER ']' Expression ';';
JumpStatement		:	RETURN ';' | RETURN Expression ';' ;
Expression		:	IdentifierAssignment '=' Expression | SimpleExpression ;
IdentifierAssignment    :	IDENTIFIER ;
SimpleExpression	:	SimpleExpression RelationOperator AdditionExpression | AdditionExpression ;
RelationOperator	:	LE | '<'| '>' | GE | EQ | NE ;
AdditionExpression	:	AdditionExpression AdditionOperator Term | Term ;
AdditionOperator	:	'+' | '-' ;
Term			:	Term ProductOperator Factor | Factor ;
ProductOperator		:	'*' | '/' ;
Factor			:	'(' Expression ')' | IdentifierAssignment | Call | Number ;
Call			:	IDENTIFIER '(' Arguments ')' ;
Arguments		:	ArgumentList | ;
ArgumentList		:	ArgumentList ',' Expression | Expression ;
Number			:	PositiveNumber | NegativeNumber ;
PositiveNumber		:	'+' Value | Value ;
NegativeNumber		:	'-' Value ;
Value			:	INTEGER_NUMBER | FLOAT_NUMBER ;

%%

#include"lex.yy.c"

void yyerror(const char *s)
{
	printf("%d : %s %s\n", yylineno, s, yytext );
}
int main(int argc, char *argv[])
{
  yyin = fopen(argv[1], "r");
  if(!yyparse())
    printf("\nParsing complete\n");
  else
    printf("\nParsing failed\n");
  fclose(yyin);
  return 0;
} 
