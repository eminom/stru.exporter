
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"


int yylex(void);

//#define PRT(...)	{printf(__VA_ARGS__);puts("");}
#define PRT(...)

%}

%%
struct 	{
	PRT("struct");
	return T_STRUCT;
}

std::string									{
	PRT("string");
	return T_STRING;
}

int 												{
	PRT("int");
	return T_INT;
}

[a-zA-Z][a-zA-Z0-9_]*				{
	PRT("var");
	yylval = (int)strdup(yytext);
	return VAR;
}

;														{
	PRT("semicolon");
	return S_SEMICOLON;
}

\{	   											{
	PRT("left bracket");
	return S_LBRACKET;
}

\}		  										{
	PRT("right bracket");
	return S_RBRACKET;
}

[ \t\n\r]					          ;	/*remove white space*/
.         { printf("Unknown token\n");}


%%

int yywrap(void)
{
	return 1;
}
