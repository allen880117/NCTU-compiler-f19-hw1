%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenChar(t)       {LIST; if (Opt_T) printf("<%c>\n", (t));}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, (i));}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, (s));}
// Define your token macros here
//  for example :
//    #define tokenScientific(t, s)   <definition>
//    #define tokenFloat(ts)          <definition>
//    #define <any other macros you needed>

#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
char tempStringBuf[MAX_LINE_LENG];
char StringBuf[MAX_LINE_LENG];
%}

%Start COMMENT

Character [^\n\"]*
String \"{Character}((\"\"){Character})*\"

OperatorMod "mod"
OperatorAnd "and"
OperatorOr  "or"
OperatorNot "not"

NumInteger ([1-9][0-9]*)|(0)
NumFloat ({NumInteger}\.[0-9]*[1-9])|({NumInteger}\.0)
NumScientific  ({NumFloat}|{NumInteger})[Ee][+|-]?{NumInteger}
NumOctInteger   (0[0-7][0-7]*)

KWarray   "array"
KWbegin   "begin"
KWboolean "boolean"
KWdef     "def"
KWdo      "do"
KWelse    "else"
KWend     "end"
KWfalse   "false"
KWfor     "for"
KWinteger "integer"
KWif      "if"
KWof      "of"
KWprint   "print"
KWread    "read"
KWreal    "real"
KWstring  "string"
KWthen    "then"
KWto      "to"
KWtrue    "true"
KWreturn  "return"
KWvar     "var"
KWwhile   "while"

VariableName [a-zA-Z][0-9a-zA-Z]*

%%

{String}  {
            strncat(tempStringBuf, yytext+1, strlen(yytext)-2);
            
            int idx=0;
            while(idx<strlen(tempStringBuf)){
              strncat(StringBuf, tempStringBuf+idx, 1);
              
              if(tempStringBuf[idx]=='\"') idx+=2;
              else idx++;
            }
            tokenString(string, StringBuf);
            
            tempStringBuf[0] = '\0';
            StringBuf[0] = '\0';
          }

"//&S-".*     { LIST; Opt_S = 0; } 
"//&S+".*     { LIST; Opt_S = 1; }
"//&T-".*     { LIST; Opt_T = 0; }
"//&T+".*     { LIST; Opt_T = 1; }

"//".*  { LIST; }
"/*"    {
          LIST;
          
          int c1=0;
          int c2=input();
          
          for(;;){
            if(c2 == EOF) break ;
            
            char str[2];
            str[0] = c2;
            str[1] = '\0';
            strcat(buf, str);
                
            if(c2 == '\n'){
              if (Opt_S)
                printf("%d: %s", linenum, buf); // WA : Remove \n
              linenum++;
              buf[0] = '\0';
            }
            
            if(c1 == '*' && c2 == '/') {
              break;
            }
            
            c1 = c2;
            c2 = input();
          }
        }
             
{KWarray}   { token(KWarray); }
{KWbegin}   { token(KWbegin); }
{KWboolean} { token(KWboolean); }
{KWdef}     { token(KWdef); }
{KWdo}      { token(KWdo); }
{KWelse}    { token(KWelse); }
{KWend}     { token(KWend); }
{KWfalse}   { token(KWfalse); }
{KWfor}     { token(KWfor); }
{KWinteger} { token(KWinteger); }
{KWif}      { token(KWif); }
{KWof}      { token(KWof); }
{KWprint}   { token(KWprint); }
{KWread}    { token(KWread); }
{KWreal}    { token(KWreal); }
{KWstring}  { token(KWstring); }
{KWthen}    { token(KWthen); }
{KWto}      { token(KWto); }
{KWtrue}    { token(KWtrue); }
{KWreturn}  { token(KWreturn); }
{KWvar}     { token(KWvar); }
{KWwhile}   { token(KWwhile); }

{OperatorMod}      { token(mod);}
{OperatorAnd}      { token(and);}
{OperatorOr}       { token(or); }
{OperatorNot}      { token(not);}

{VariableName} { tokenString(id, yytext); }

{NumScientific} { tokenString(scientific, yytext); } // scientific
{NumFloat}      { tokenString(float, yytext); } // float first
{NumInteger}    { tokenString(integer, yytext); } // integer follow
{NumOctInteger} { tokenString(oct_integer, yytext); } 

"+"         { tokenChar('+');  } // Should After Scientific Notations
"-"         { tokenChar('-');  }
"*"         { tokenChar('*');  } // Should After Comment 
"/"         { tokenChar('/');  } // Should After Comment 
":="        { token(:=); }
"<="        { token(<=); } // Should Before < and =
"<>"        { token(<>); } // Should Before < and >
">="        { token(>=); }
"<"         { tokenChar('<');  }
">"         { tokenChar('>');  }
"="         { tokenChar('=');  }
","         { tokenChar(','); }
";"         { tokenChar(';'); }
":"         { tokenChar(':'); }
"("         { tokenChar('('); }
")"         { tokenChar(')'); }
"["         { tokenChar('['); }
"]"         { tokenChar(']'); }

<COMMENT>\n |
\n          {
              LIST;
              if (Opt_S)
                printf("%d: %s", linenum, buf); // WA : Remove \n
              linenum++;
              buf[0] = '\0';
            }
[ \t]+      { LIST; }     
.           {
              /* error */
              printf("Error at line %d: bad character \"%s\"\n", linenum, yytext ); // WA : error -> Error
              exit(-1);
            }
%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}
