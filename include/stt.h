/** Syntax Tree Tool est un outil permettant de définir des arbres 
 *  syntaxique en C et de les parcourir. 
 *
 *  Toutes fonctions prennant en paramètre un Node sont conçus pour fonctionner
 *  avec des Node qui ont été généré à l'aide des fonctions de génération :
 *    - node_value
 *    - node_id 
 *    - node_op 
 *    - node_inst
 *    - node_if
 *    - node_ret
 *    - node_aff
 *  */

#ifndef __STT_H__
#define __STT_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "llist.h"
#include "hashtable.h"
#include "util.h"


typedef enum node_type{
  // EXPRESSION
  VALUE,
  ID,
  OPER,
  // AFFECTATION
  AFF,
  INST,
  // FUNCTIONS
  FUN,
  RET, 
  CALL,
  MAIN,
  EFUN,
  // CONDITIONS
  IF,
  ELSE,
  COND,
  EIF,
  // BOUCLES
  WHILE,
  EWHILE
} node_type;

typedef enum v_type {
  INT_T, 
  BOOL_T,
  UNKNOW_T
} v_type;

typedef enum op_type{
  // ARITHMETIQUE
  OP_ADD,
  OP_SUB,
  OP_MUL,
  OP_DIV,
  // BOOL
  OP_EQ,
  OP_NE,
  OP_LT,
  OP_GT,
  OP_LE,
  OP_GE,
  OP_AND,
  OP_OR,
  OP_NOT,
  OP_BOOL
} op_type;

typedef struct op_args {
  op_type type;
  v_type v_type;
} op_args;

typedef struct if_args{
  int value;
} if_args;

typedef enum id_type{
  GLO_ID,
  ARGS_ID,
  FUN_ID,
  LOC_ID,
  RET_ID,
  UNKNOW_ID
} id_type;

typedef struct id_args {
  id_type type;
  char * identifier;
  v_type v_type;
} id_args;

typedef struct Node {
  node_type type;
  struct Node * left;
  struct Node * right;
  union{
    int value;
    op_args * op_args;
    id_args * id_args;
    if_args * if_args;
  };
} Node;

// CONTAINING_RETURN_FOR_ALL_CASES() : est une macro-fonction qui prend un 
// Node n et un entier r. Cette macro-fonction affecte à r 1 lorsque il est 
// possible à partir du Node * n d'atteindre pour tous les cas un Node de type 
// ret.
#define CONTAINING_RETURN_FOR_ALL_CASES(n, r) \
      while(n != NULL){                       \
        if(n->type == IF &&                   \
            n->if_args->value == 1){          \
          r = 1;                              \
          break;                              \
        }                                     \
        if(n->type == RET ||                  \
          (n->type == INST &&                 \
            n->left->type == RET)){           \
          r = 1;                              \
          break;                              \
        }                                     \
        n = n->right;                         \
      } 

// CHECK_END_OF_INST() : prend en entrée un Node n le parcours et affecte à 
// r 1 si la fin du parcours mène à un Node de type end.
#define CHECK_END_OF_INST(end, n, r)  \
      while(n != NULL){               \
        if(n->type == end){           \
          r = 1;                      \
          break;                      \
        }                             \
        if(n->type == ELSE){          \
          n = n->left;                \
        } else{                       \
          n = n->right;               \
        }                             \
      }

// node_value : prend en entré un entier valeur et alloue les 
// ressources suffisantes pour générer un Node de type VALUE. Renvoie 
// le noeud en cas de succès, NULL sinon.
extern Node * node_value(int value);

// ASM_NODE_VALUE : prend en entré un Node et affiche sur la sortie standard 
// le code assembleur correspondant au type de Node value.
#define ASM_NODE_VALUE(node)    \
  if(node->type == VALUE) {     \
    ASM_PUSH(node->value);      \
  }


// node_id : prend en entré une chaine de caractère identifier et 
// alloue les ressources suffisantes pour générer un Node de type ID. Renvoie 
// le Node en cas de succès, NULL sinon.
extern Node * node_id(char * identifier, id_type type);

// SET_ID_TYPE() : défini le v_type de l'entier id au type vtype.
#define SET_ID_TYPE(id, vtype)                                              \
      if(id->type == ID){                                                   \
        if(id->id_args->v_type != UNKNOW_T && id->id_args->v_type != vtype){\
          fprintf(stderr,                                                   \
            "ERROR : bad type for var %s\n",                                \
            id->id_args->identifier);                                       \
          exit(EXIT_FAILURE);                                               \
        }                                                                   \
        else{                                                               \
          id->id_args->v_type = vtype;                                      \
        }                                                                   \
      }

// node_op : prend en entré un operator de type op_type, un Node left et 
// un Node right et alloue les ressources suffisantes pour générer un Node de 
// type OPER. Renvoie le Node en cas de succès, NULL sinon.
extern Node * node_op(op_type operator, Node * left, Node * right);

// ASSERT_OP_TYPE_INT() : Vérifie sur les deux Node sont de v_type INT_T
#define ASSERT_OP_TYPE_INT(l, r)                                              \
    if((l->type == OPER && l->op_args->v_type != INT_T)                       \
    || (r->type == OPER && r->op_args->v_type != INT_T)                       \
    || ((l->type == ID || l->type == CALL) && l->id_args->v_type != INT_T)    \
    || ((r->type == ID || r->type == CALL) && r->id_args->v_type != INT_T)){  \
      fprintf(stderr, "ERROR : invalid type\n");                              \
      exit(EXIT_FAILURE);                                                     \
    }

// ASSERT_OP_TYPE_INT() : Vérifie sur les deux Node, l et r, sont de v_type 
// BOOL_T
#define ASSERT_OP_TYPE_BOOL(l, r)                                             \
    if((l->type == OPER && l->op_args->v_type != BOOL_T)                      \
    || (r->type == OPER && r->op_args->v_type != BOOL_T)                      \
    || ((l->type == ID || l->type == CALL) && l->id_args->v_type != BOOL_T)   \
    || ((r->type == ID || r->type == CALL) && r->id_args->v_type != BOOL_T)){ \
      fprintf(stderr, "ERROR : invalid type\n");                              \
      exit(EXIT_FAILURE);                                                     \
    }

// VTYPE_OF_NODE() : Affecte à vt, le v_type du Node n.
#define VTYPE_OF_NODE(n, vt)        \
  switch(n->type){                  \
    case OPER:                      \
      vt = n->op_args->v_type;      \
      break;                        \
    case ID :                       \
    case CALL :                     \
      vt = n->id_args->v_type;      \
      break;                        \
    default :                       \
      vt = INT_T;                   \
      break;                        \
  }

// SET_TYPE_OF_NODE() : Affecte au Node n, le v_type du vt.
#define SET_TYPE_OF_NODE(n, vtype)  \
  switch(n->type){                  \
    case OPER:                      \
      n->op_args->v_type = vtype;   \
      break;                        \
    case ID :                       \
    case CALL :                     \
      n->id_args->v_type = vtype;   \
      break;                        \
    default :                       \
    break;                          \
  }


// node_aff : prend en entré un node de type ID et un node expression et 
// alloue les ressources nécessaire à la création d'un Node de type AFF. 
// Renvoie le Node en cas de succès, NULL sinon.
extern Node * node_aff(Node * id, Node * expr);

// node_inst : prend en entré un Node représentant une instruction et alloue 
// les ressources nécessaire à la création d'un Node de type INST. Renvoie le
// Node en cas de succès, NULL sinon.
extern Node * node_inst(Node * instruction);

// node_if : prend en entré un Node représentant la condition booléenne à 
// satisfaire pour exécuter les instructions du noeud gauche. Renvoie le 
// Node en cas de succès, NULL sinon.
extern Node * node_if(Node * inst);

// node_ret : prend en entré un Node représentant une instruction de retour
// et alloue les ressources nécessaire à la création de ce Node de type RET. 
// Renvoie le Node en cas de succès, NULL sinon.
extern Node * node_ret(Node * expr);

// node_dispose : prend en entré un pointeur vers un pointeur de Node et 
// libère les ressources qui lui sont associées.
extern void node_dispose(Node ** nptr);

// node_fun_dispose : prend en entré un pointeur vers un pointeur de Node et 
// libère les ressources qui lui sont associées.
extern void node_fun_dispose(Node ** nptr, hashtable * ht);

// node_print_fun_asm : prend en entré une racine d'un arbre de noeud, 
// la table des symboles correspondante et renvoie le code assembleur 
// correspondant.
extern int node_print_fun_asm(Node * root, hashtable * ht);

// count_args : prend en entrée un Node node et un pointeur vers un entier acc.
// Dans le cas où le Node est de type ID et que son id_type est de type 
// "ARGS_ID", ajoute à acc 1.
extern int count_args(Node * node, int * acc);

// is_type_defined : prend en entrée un Node node et un pointeur vers un 
// entier. Si le Node est de type ID et que son v_type n'est pas défini, 
// renvoie -1. Sinon, ajoute à acc 1.
extern int is_type_defined(Node * node, int * acc);

// nidcmp : fonction de comparaisons entre deux Node de type ID. Applique 
// la fonction strcmp sur les deux identifiants des Node et renvoie le résultat.
extern int nidcmp(Node * x, Node * y);

#endif // __STT_H__
