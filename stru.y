
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

#define MaxFields			100
#define StrSiz				80
#define StackDepth		12

//FieldType 
enum {
	FT_Integer,		//some operand manipulated by APIs such as lua_pushinteger
	FT_String,			//lua_pushstring   string terminated by zero
	FT_Float				//lua_pushnumber (double)
};

struct StruChunk
{
	char gStructName[StrSiz];
	char gFields[MaxFields][StrSiz];
	int gFieldTypes[MaxFields];
	int gFieldCounter;
	int gIsArray;
	int gAcceptedType;
};

struct StruChunk* allocStruChunk()
{
	struct StruChunk *rv = (struct StruChunk*)malloc(sizeof(struct StruChunk));
	memset(rv, 0, sizeof(*rv));
	return rv;
}

struct StruChunk *gChunk;
struct StruChunk *gStack[StackDepth];
int gTop = -1;

void writeStructFile(struct StruChunk*);

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
| 
;

SingleGeneralStatement:
Struct Semicolon
|Semicolon
;

StructName:
Var		{ strcpy(gChunk->gStructName, $1);}
|			{ strcpy(gChunk->gStructName,""); }
;

KeyStruct:
TStruct { 
	++gTop;
	gStack[gTop] = gChunk;
	gChunk = allocStruChunk(); 
}
;

Struct:
KeyStruct StructName Left DefinesOpt Right
		{
			writeStructFile(gChunk);		//Output to stdout
		}
;

DefinesOpt:
SingleDefine DefinesOpt
|
;

TypeToken:
TInteger			{   gChunk->gFieldTypes[gChunk->gFieldCounter] = FT_Integer;  gChunk->gAcceptedType = 1;}
|TString			{		gChunk->gFieldTypes[gChunk->gFieldCounter] = FT_String;   gChunk->gAcceptedType = 1;}
|TBoolean			{   gChunk->gAcceptedType = 0; }
|TFloat				{   gChunk->gAcceptedType = 0; }
|TCCPoint			{   gChunk->gAcceptedType = 0; }


SingleDefine:
TypeToken VarObj Semicolon		{ 
	if(gChunk->gAcceptedType && !gChunk->gIsArray){
		gChunk->gFieldCounter++;
	}
}
|Semicolon  {}
;

VarObj:
Var																		{ strcpy(gChunk->gFields[gChunk->gFieldCounter], $1); gChunk->gIsArray = 0;}
| Var SquaLeft Decimals SquaRight 		{ gChunk->gIsArray = 1; /*Just ignore array for now  */}
| Var SquaLeft Var      SquaRight			{ gChunk->gIsArray = 1; }
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
void writeStructFile(struct StruChunk *now)
{
	printf("{");
	printf("\"name\":\"%s\", ", now->gStructName);
  printf("\"struct\":{");
	for(int i=0;i<now->gFieldCounter;++i){
		printf("\"%s\":\"%s\"", now->gFields[i], getTypeStringRep(now->gFieldTypes[i]));
		if(i<now->gFieldCounter-1){
			printf(",");
		}
	}

	printf("}");
	printf("}\n\n");

	//reset for the next one
	//gFieldCounter = 0;
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




