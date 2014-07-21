
%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define YYSTYPE	char*
int yylex(void);
void yyerror(char *);
extern int yylineno;

//#define PRINT(...)	{printf(__VA_ARGS__);puts("");}
#define PRINT(...)

#define _MAX_FIELDS	100

//FieldType 
enum {
	FT_Integer,		//some operand manipulated by APIs such as lua_pushinteger
	FTString,			//lua_pushstring   string terminated by zero
	FT_Float				//lua_pushnumber (double)
};

char gStructName[BUFSIZ];
char gFields[_MAX_FIELDS][BUFSIZ];
int gFieldTypes[_MAX_FIELDS];
int gFieldCounter = 0;

void writeStructFile();

%}

%token Decimals
%token Left Right 
%token Semicolon
%token SquaLeft SquaRight
%token Var 
%token TStruct TInteger TString 
%token TBoolean
%token TCCPoint
%token TFloat

%%

GeneralStatementsOpt:
SingleGeneralStatement GeneralStatementsOpt
|Semicolon
;

SingleGeneralStatement:
Struct Semicolon
|Semicolon
;

Struct:
TStruct Var Left StatementsOpt Right
		{
			PRINT("struct %s defined", $2);
			strcpy(gStructName, $2);
			writeStructFile();		//Output to stdout
		}
;

StatementsOpt:
SingleStatement StatementsOpt
|
;

SingleStatement:
TInteger Var Semicolon					
	{
		PRINT("int %s defined", $2);
		strcpy(gFields[gFieldCounter], $2);
		gFieldTypes[gFieldCounter] = FT_Integer;
		++gFieldCounter;
	}
|TString Var Semicolon
	{
		PRINT("std::string %s defined", $2);
		strcpy(gFields[gFieldCounter], $2);
		gFieldTypes[gFieldCounter] = FTString;
		++gFieldCounter;
	}
|TBoolean Var Semicolon {}
|TCCPoint Var Semicolon {}
|TInteger Var SquaLeft Decimals SquaRight Semicolon  {}
|TInteger Var SquaLeft Var SquaRight Semicolon       {}
|TFloat Var Semicolon {
		PRINT("float %s defined", $2);
		strcpy(gFields[gFieldCounter], $2);
		gFieldTypes[gFieldCounter] = FT_Float;
		++gFieldCounter;
}

|TFloat Var SquaLeft Var SquaRight Semicolon      {}
|TFloat Var SquaLeft Decimals SquaRight Semicolon {}
;
%%

void yyerror(char *err)
{
	//printf("error:%s,  line %d\n",err, yylineno);
	printf("error:%s, line %d\n", err, yylineno);
}


const char* getTypeStringRep(int type){
	const char* rv = "";
	switch(type){
	case FTString:
		rv = "string";
		break;
	case FT_Integer:
		rv = "integer";
		break;
	case FT_Float:
		rv = "float";
		break;
	default:
		printf("No no no, invalid type no.\n");
		abort();
		break;
	}
	return rv;
}

//Inputs are all global vars
void writeStructFile()
{
	printf("{");
	printf("\"name\":\"%s\", ", gStructName);
  printf("\"struct\":{");
	for(int i=0;i<gFieldCounter;++i){
		printf("\"%s\":\"%s\"", gFields[i], getTypeStringRep(gFieldTypes[i]));
		if(i<gFieldCounter-1){
			printf(",");
		}
	}


	printf("}");
	printf("}\n\n");

	//reset for the next one
	gFieldCounter = 0;
}

int main(void)
{
	//yyparse return 0 for valid inputs
	//non-zero for parsing error
  if(yyparse()){
		printf("error parsing\n");
	}
	return 0;
}




