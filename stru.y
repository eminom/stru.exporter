
%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define YYSTYPE	char*
int yylex(void);
void yyerror(char *);

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
int gFieldCounter;

%}

%token DIGITALS
%token S_LBRACKET S_RBRACKET 
%token S_SEMICOLON
%token S_LSQ S_RSQ
%token VAR 
%token T_STRUCT T_INT T_STRING 
%token T_BOOLEAN
%token T_CCPOINT

%%
struct:
T_STRUCT VAR S_LBRACKET statement S_SEMICOLON  
		{
			PRINT("struct %s defined", $2);
			strcpy(gStructName, $2);
		}
|
;

statement:
T_INT VAR S_SEMICOLON statement					
	{
		PRINT("int %s defined", $2);
		strcpy(gFields[gFieldCounter], $2);
		gFieldTypes[gFieldCounter] = FT_Integer;
		++gFieldCounter;
	}
|T_STRING VAR S_SEMICOLON statement 		
	{
		PRINT("std::string %s defined", $2);
		strcpy(gFields[gFieldCounter], $2);
		gFieldTypes[gFieldCounter] = FT_String;
		++gFieldCounter;
	}
|T_BOOLEAN VAR S_SEMICOLON statement  {}
|T_CCPOINT VAR S_SEMICOLON statement  {}
|T_INT VAR S_LSQ DIGITALS S_RSQ S_SEMICOLON statement {}
|T_INT VAR S_LSQ VAR S_RSQ S_SEMICOLON statement      {}
|S_RBRACKET			{}
;
%%

void yyerror(char *err)
{
	printf("error:%s\n",err);
}


const char* getTypeStringRep(int type){
	const char* rv = "";
	switch(type){
	case FT_String:
		rv = "string";
		break;
	case FT_Integer:
		rv = "integer";
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
	printf("}");
}

int main(void)
{
	//yyparse return 0 for valid inputs
	//non-zero for parsing error
  if(0==yyparse()){
		writeStructFile();
	} else {
		printf("error parsing\n");
	}
	return 0;
}




