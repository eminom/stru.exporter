
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
	char structName[StrSiz];
	char fields[MaxFields][StrSiz];
	int fieldTypes[MaxFields];
	int fieldCounter;
	int isArray;
	int accepted;
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
Var		{ strcpy(gChunk->structName, $1);}
|			{ strcpy(gChunk->structName,""); }
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
TInteger			{   gChunk->fieldTypes[gChunk->fieldCounter] = FT_Integer;  gChunk->accepted = 1;}
|TString			{		gChunk->fieldTypes[gChunk->fieldCounter] = FT_String;   gChunk->accepted = 1;}
|TBoolean			{   gChunk->accepted = 0; }
|TFloat				{   gChunk->accepted = 0; }
|TCCPoint			{   gChunk->accepted = 0; }


SingleDefine:
TypeToken VarObj Semicolon		{ 
	if(gChunk->accepted && !gChunk->isArray){
		gChunk->fieldCounter++;
	}
}
|Semicolon  {}
;

VarObj:
Var																		{ strcpy(gChunk->fields[gChunk->fieldCounter], $1); gChunk->isArray = 0;}
| Var SquaLeft Decimals SquaRight 		{ gChunk->isArray = 1; /*Just ignore array for now  */}
| Var SquaLeft Var      SquaRight			{ gChunk->isArray = 1; }
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
	printf("\"name\":\"%s\", ", now->structName);
  printf("\"struct\":{");
	for(int i=0;i<now->fieldCounter;++i){
		printf("\"%s\":\"%s\"", now->fields[i], getTypeStringRep(now->fieldTypes[i]));
		if(i<now->fieldCounter-1){
			printf(",");
		}
	}

	printf("}");
	printf("}\n\n");

	//reset for the next one
	//fieldCounter = 0;
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




