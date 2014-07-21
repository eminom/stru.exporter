
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


//YYSTYPE must come before y.tab.h
#define YYSTYPE	char*
#include "y.tab.h"

int yylex(void);

//#define PRT(...)	{printf(__VA_ARGS__);puts("");}
#define PRT(...)

%}

%%
struct 	{
	PRT("struct");
	return TStruct;
}

std::string									{
	PRT("string");
	return TString;
}

int 												{
	PRT("int");
	return TInteger;
}

float	{ return TFloat;}

CCPoint											{
	PRT("CCPoint");
	return TCCPoint;
}

bool												{
	PRT("bool");
	return TBoolean;
}

[a-zA-Z][a-zA-Z0-9_]*				{
	PRT("var");
	//Do not depend on cast(it may lose precision)
	yylval = strdup(yytext);
	return Var;
}

[0-9]+											{
	PRT("decimal");
	return Decimals;
}

;														{
	PRT("semicolon");
	return Semicolon;
}

\{	   											{
	PRT("left bracket");
	return Left;
}

\}		  										{
	PRT("right bracket");
	return Right;
}

\[     {
	PRT("left square bra");
	return SquaLeft;
}

\]	{
	PRT("right square bra");
	return SquaRight;
}

[ \t\n\r]					          ;	/*remove white space*/
.         { printf("Unknown token\n");}


%%

int yywrap(void)
{
	return 1;
}
