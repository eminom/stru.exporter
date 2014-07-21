
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
	FT_String,			//lua_pushstring   string terminated by zero
	FT_Float				//lua_pushnumber (double)
};

char gStructName[BUFSIZ];
char gFields[_MAX_FIELDS][BUFSIZ];
int gFieldTypes[_MAX_FIELDS];
int gFieldCounter = 0;

//Only !gIsArray && gAcceptedType do we move on
int gIsArray = 0;
int gAcceptedType = 0;

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
| 
;

SingleGeneralStatement:
Struct Semicolon
|Semicolon
;

Struct:
TStruct Var Left DefinesOpt Right
		{
			PRINT("struct %s defined", $2);
			strcpy(gStructName, $2);
			writeStructFile();		//Output to stdout
		}
;

DefinesOpt:
SingleDefine DefinesOpt
|
;

TypeToken:
TInteger			{   gFieldTypes[gFieldCounter] = FT_Integer;  gAcceptedType = 1;}
|TString			{		gFieldTypes[gFieldCounter] = FT_String;   gAcceptedType = 1;}
|TBoolean			{   gAcceptedType = 0; }
|TFloat				{   gAcceptedType = 0; }
|TCCPoint			{   gAcceptedType = 0; }


SingleDefine:
TypeToken VarObj Semicolon		{ 
	if(gAcceptedType && !gIsArray){
		gFieldCounter++;
	}
};

VarObj:
Var																		{ strcpy(gFields[gFieldCounter], $1); gIsArray = 0;}
| Var SquaLeft Decimals SquaRight 		{ gIsArray = 1; /*Just ignore array for now  */}
| Var SquaLeft Var      SquaRight			{ gIsArray = 1; }
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
	case FT_String:		rv = "string";		break;
	case FT_Integer:	rv = "integer";		break;
	case FT_Float:		rv = "float"; 		break;
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




