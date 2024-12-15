/**
 * @file util.h
 * @author Lucas Coussement (lucas.coussement@univ-rouen.fr)
 * @brief Fichier d'en-tête pour la définition des fonctions ainsi que des 
 *     constantes utilisées dans le cadre du projet de compilation.
 */
#ifndef __UTIL_H__
#define __UTIL_H__

#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#define STACK_NAME "stack"
#define START_NAME "start"
#define DIV_ZERO_NAME "div_zero"
#define EQ_NAME "eq"
#define NE_NAME "ne"
#define LT_NAME "lt"
#define LE_NAME "le"
#define GT_NAME "gt"
#define GE_NAME "ge"
#define NOT_NAME "not"
#define TRUE_NAME "true"
#define FALSE_NAME "false"

#define HEADER() printf(        \
    "\tconst ax,%s\n"           \
    "\tjmp ax\n"                \
    ":%s\n"                     \
    "\tconst bp,%s\n"           \
    "\tconst sp,%s\n"           \
    "\tconst ax,2\n"            \
    "\tsub sp,ax\n"             \
    ,START_NAME, START_NAME,    \
    STACK_NAME, STACK_NAME)

#define FUN_HEADER(name) printf(\
    ":fun%s\n"                  \
    "\tpush bp\n"               \
    "\tcp bp,sp\n"              \
    , name)

#define FUN_FOOTER() printf(    \
    "\tpop ax\n"                \
    "\tcp bp,ax\n"              \
    "\tret\n"                   \
)

#define FOOTER() printf(        \
    "\tcp ax,sp\n"              \
    "\tpop ax\n"                \
    "\tend\n"                   \
    )

#define NL_LABEL() printf(      \
    ":nl\n"                     \
    "@string \"\\n\"\n"         \
    )

#define LOAD_ADDR(addr) printf( \
    "\tconst cx, if-%d\n"       \
    , addr                      \
    )
#define JMPZ() printf (         \
    "\tjmpz cx\n"               \
)

#define CALC_IF_LABEL(iflevel, ifcount) \
  for(int k = 0; k < iflevel + 1; k++){ \
    printf("i");                        \
  }                                     \
  printf("%d\n",ifcount)              

#define CHECK_COND()            \
  printf(                       \
    "\tpop ax\n"                \
    "\tconst bx,0\n"            \
    "\tsub ax,bx\n"             \
    "\tjmpz cx\n")

#define DIV_ZERO_LABEL()                        \
    printf(                                     \
    ":text-%s\n"                                \
    "@string \"error: Division par zéro\\n\"\n" \
    ":%s\n"                                     \
    "\tconst ax,text-%s\n"                      \
    "\tcallprintfs ax\n"                        \
    "\tend\n"                                   \
    ,DIV_ZERO_NAME, DIV_ZERO_NAME,              \
    DIV_ZERO_NAME)

#define CREATE_VAR_LABEL(name)                  \
    printf(                                     \
    ":var-%s\n"                                 \
    "@int 0\n"                                  \
    ,name)
#define CREATE_IF_LABEL(name)                   \
    printf(                                     \
    ":if-%d\n"                                  \
    ,name                                       \
    )

#define EQ_LABELS(name, op, opt1, opt2)         \
    printf(                                     \
    ":%s\n"                                     \
    "\tconst cx,%s\n"                           \
    "\t%s ax,bx\n"                              \
    "\tjmpc cx\n"                               \
    "\tconst ax,%s\n"                           \
    "\tjmp ax\n"                                \
    ,name, opt1, op, opt2)

#define EQ_LABELS_2(name, op1, op2, opt1, opt2) \
    printf(                                     \
    ":%s\n"                                     \
    "\tconst cx,%s\n"                           \
    "\t%s ax,bx\n"                              \
    "\tjmpc cx\n"                               \
    "\t%s ax,bx\n"                              \
    "\tjmpc cx\n"                               \
    "\tconst ax,%s\n"                           \
    "\tjmp ax\n"                                \
    ,name, opt1, op1, op2, opt2)

#define AX_AFFECT_LABEL(name, value)    \
    printf(                             \
    ":%s\n"                             \
    "\tconst ax,%s\n"                   \
    "\tret\n"                           \
    ,name, value)

#define END() printf(           \
    ":%s\n"                     \
    "@int 0\n"                  \
    ,STACK_NAME)

#define ASM_PUSH(num) printf(   \
    "\tconst ax,%d\n"           \
    "\tpush ax\n", num          \
    )

#define ASM_OPER(op)            \
    printf(                     \
    "\tpop bx\n"                \
    "\tpop ax\n"                \
    "\t%s ax,bx\n"              \
    "\tpush ax\n"               \
    ,op)

#define ASM_OPER_ERR(op, on_err)\
    printf(                     \
    "\tconst cx,%s\n"           \
    "\tpop bx\n"                \
    "\tpop ax\n"                \
    "\t%s ax,bx\n"              \
    "\tjmpe cx\n"               \
    "\tpush ax\n"               \
    ,on_err, op)

#define ASM_CALL(name)            \
    printf(                       \
        "\tconst cx,%s\n"         \
        "\tpop bx\n"              \
        "\tpop ax\n"              \
        "\tcall cx\n"             \
        "\tpush ax\n"             \
    ,name)

#define ASM_CALL_ON_ONE(name, value)    \
    printf(                             \
        "\tconst cx,%s\n"               \
        "\tconst bx, %d\n"              \
        "\tpop ax\n"                    \
        "\tcall cx\n"                   \
        "\tpush ax\n"                   \
    ,name, value)

#define ASM_CALL_FUN(name)        \
    printf(                       \
        "\tconst cx,fun%s\n"      \
        "\tcall cx\n"             \
        , name)

#define SUB_SP(num)             \
    printf(                     \
        "\tconst ax,%d\n"       \
        "\tsub sp,ax\n"         \
        ,(2 * num) - 2)

#define ASM_PRINT() printf(     \
    "\tcp ax,sp\n"              \
    "\tcallprintfd ax\n"        \
    "\tpop ax\n"                \
    "\tconst ax,%s\n"           \
    "\tcallprintfs ax\n"        \
    , "nl")

#define STORE_IN_LABEL(name)    \
    printf(                     \
    "\tpop ax\n"                \
    "\tconst bx,var-%s\n"       \
    "\tstorew ax,bx\n"          \
    ,name)

#define STORE_IN_VAR(num)       \
    printf(                     \
      "\tconst bx,%d\n"         \
      "\tsub bp,bx\n"           \
      "\tpop ax\n"              \
      "\tstorew ax,bp\n"        \
      "\tadd bp,bx\n"           \
      ,num * 2 + 2              \
    )

#define LOAD_FROM_LABEL(name)   \
    printf(                     \
    "\tconst bx,var-%s\n"       \
    "\tloadw ax,bx\n"           \
    "\tpush ax\n"               \
    ,name)

#define LOAD_FROM_VAR(num)      \
    printf(                     \
      "\tconst bx,%d\n"         \
      "\tsub bp,bx\n"           \
      "\tloadw ax,bp\n"         \
      "\tpush ax\n"             \
      "\tadd bp,bx\n"           \
      ,num * 2 + 2              \
    )

/** int_from_string : prend en entrée une chaîne de
 * caractères représentant un entier et un pointeur sur un entier. La fonction
 * affecte à l'entier pointé par num la valeur de l'entier représenté par la 
 * chaîne str si la chaîne est bien formée. La fonction renvoie 0 si la chaîne
 * est bien formée, -1 sinon.
 */
extern int int_from_string(char * str, int16_t * num);

/** hashfun : Prend en entrée un const void * keyref et renvoie un entier unique
 * pour chaque clé.
*/
extern size_t hashfun(const void * s);

/** compar : Prend en entrée deux const void * a et b et renvoie un entier
 * négatif si a < b, un entier positif si a > b et 0 si a = b.
*/
extern int compar(const void *a, const void *b);

#endif // __UTIL_H__
