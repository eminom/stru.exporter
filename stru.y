
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

%token S_LBRACKET S_RBRACKET VAR T_STRUCT T_INT T_STRING S_SEMICOLON

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
  yyparse();
	//printf("Everything turns into dust.\n");
	//
	//printf("struct:%s\n", gStructName);
	//int i=0;
	//for(i=0;i<gFieldCounter;++i){
	//	printf("%s:%d\n", gFields[i], gFieldTypes[i]);
	//}
	writeStructFile();
	return 0;
}




