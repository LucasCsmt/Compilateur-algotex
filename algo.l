%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "stt.h"
    #include "hashtable.h"
    #include "util.h"
    #include "algo.tab.h"
%}

%option noyywrap

%%

[[:blank:]]    {}

\\SET {
  return SET;
}

\\DOWHILE {
  return DOWHILE;
}

\\DOFORI {
  return DOFORI;
}

\\IF {
  return DIF;
}

\\ELSE {
  return DELSE;
}

\\FI {
  return FI;
}

\\OD {
  return OD;
}

\\begin\{algo\} {
  return ALGO;
}

\\end\{algo\} {
  return EALGO;
}

\\CALL {
  return FCALL;
}

\\RETURN {
  return RETURN;
}

[+-/*()={},]    {return yytext[0];}

"\\TRUE"      {return TRUE;}
"\\FALSE"     {return FALSE;}
"<"         {return LT;}
">"         {return GT;}
">="        {return GE;}
"<="        {return LE;}
"!="        {return NE;}
"&&"        {return AND;}
"||"        {return OR;}
"!"         {return NOT;}

[a-zA-Z][a-zA-Z0-9_]*  {
  yylval.node = node_id(yytext, UNKNOW_ID);
  return SYMB;
}

[0-9]+ {
    int16_t num;
    if(int_from_string(yytext, &num) == 0){
        yylval.node = node_value(num);
        return VAL;
    } else {
        fprintf(stderr, "Error: invalid number\n");
        return EXIT_FAILURE;
    }
}
"\n" {}
.    {return EXIT_FAILURE;}
%%
