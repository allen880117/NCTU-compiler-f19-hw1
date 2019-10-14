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

<INITIAL>{String}  {
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

<INITIAL>"//&S-".*     { LIST; Opt_S = 0; } 
<INITIAL>"//&S+".*     { LIST; Opt_S = 1; }
<INITIAL>"//&T-".*     { LIST; Opt_T = 0; }
<INITIAL>"//&T+".*     { LIST; Opt_T = 1; }

<INITIAL>"//".*  { LIST; }

<INITIAL>"/*"  { LIST; BEGIN COMMENT; }
<COMMENT>"*/"  {LIST; BEGIN INITIAL; }
<COMMENT>.     {LIST; }
             
<INITIAL>{KWarray}   { token(KWarray); }
<INITIAL>{KWbegin}   { token(KWbegin); }
<INITIAL>{KWboolean} { token(KWboolean); }
<INITIAL>{KWdef}     { token(KWdef); }
<INITIAL>{KWdo}      { token(KWdo); }
<INITIAL>{KWelse}    { token(KWelse); }
<INITIAL>{KWend}     { token(KWend); }
<INITIAL>{KWfalse}   { token(KWfalse); }
<INITIAL>{KWfor}     { token(KWfor); }
<INITIAL>{KWinteger} { token(KWinteger); }
<INITIAL>{KWif}      { token(KWif); }
<INITIAL>{KWof}      { token(KWof); }
<INITIAL>{KWprint}   { token(KWprint); }
<INITIAL>{KWread}    { token(KWread); }
<INITIAL>{KWreal}    { token(KWreal); }
<INITIAL>{KWstring}  { token(KWstring); }
<INITIAL>{KWthen}    { token(KWthen); }
<INITIAL>{KWto}      { token(KWto); }
<INITIAL>{KWtrue}    { token(KWtrue); }
<INITIAL>{KWreturn}  { token(KWreturn); }
<INITIAL>{KWvar}     { token(KWvar); }
<INITIAL>{KWwhile}   { token(KWwhile); }

<INITIAL>{OperatorMod}      { token(mod);}
<INITIAL>{OperatorAnd}      { token(and);}
<INITIAL>{OperatorOr}       { token(or); }
<INITIAL>{OperatorNot}      { token(not);}

<INITIAL>{VariableName} { tokenString(id, yytext); }

<INITIAL>{NumScientific} { tokenString(scientific, yytext); } // scientific
<INITIAL>{NumFloat}      { tokenString(float, yytext); } // float first
<INITIAL>{NumInteger}    { tokenString(integer, yytext); } // integer follow
<INITIAL>{NumOctInteger} { tokenString(oct_integer, yytext); } 

<INITIAL>"+"         { tokenChar('+');  } // Should After Scientific Notations
<INITIAL>"-"         { tokenChar('-');  }
<INITIAL>"*"         { tokenChar('*');  } // Should After Comment 
<INITIAL>"/"         { tokenChar('/');  } // Should After Comment 
<INITIAL>":="        { token(:=); }
<INITIAL>"<="        { token(<=); } // Should Before < and =
<INITIAL>"<>"        { token(<>); } // Should Before < and >
<INITIAL>">="        { token(>=); }
<INITIAL>"<"         { tokenChar('<');  }
<INITIAL>">"         { tokenChar('>');  }
<INITIAL>"="         { tokenChar('=');  }
<INITIAL>","         { tokenChar(','); }
<INITIAL>";"         { tokenChar(';'); }
<INITIAL>":"         { tokenChar(':'); }
<INITIAL>"("         { tokenChar('('); }
<INITIAL>")"         { tokenChar(')'); }
<INITIAL>"["         { tokenChar('['); }
<INITIAL>"]"         { tokenChar(']'); }

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
