#include "../include/stt.h"
#include "../include/stack.h"
#include <stdio.h>
#include <stdlib.h>


Node * node_value(int value){
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    return NULL;
  }
  node->type = VALUE;
  node->value = value;
  node->left = NULL;
  node->right = NULL;
  return node;
}

id_args * id_args_init(char * identifier, id_type type){
  id_args * args = malloc(sizeof(*args));
  if(args == NULL){
    return NULL;
  }
  args->identifier = malloc(strlen(identifier) + 1);
  if(args->identifier == NULL){
    free(args);
    return NULL;
  }
  strcpy(args->identifier, identifier);
  args->type = type;
  args->v_type = UNKNOW_T;
  return args;
}

void id_args_dispose(id_args ** args){
  free((*args)->identifier);
  free(*args);
  args = NULL;
}

Node * node_id(char * identifier, id_type type){
  id_args * args = id_args_init(identifier, type);
  if(args == NULL){
    return NULL;
  }
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    id_args_dispose(&args);
    return NULL;
  }
  node->type = ID;
  node->id_args = args;
  node->left = NULL;
  node->right = NULL;
  return node;
}

op_args * op_args_init(op_type operation){
  op_args * args = malloc(sizeof(*args));
  if(args == NULL){
    return NULL;
  }
  args->type = operation;
  args->v_type = UNKNOW_T;
  return args;
}

Node * node_op(op_type operator, Node * left, Node * right){
  op_args * args = op_args_init(operator);
  if(args == NULL){
    return NULL;
  }
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    return NULL;
  }
  node->type = OPER;
  node->op_args = args;
  node->left = left;
  node->right = right;
  return node;
} 

Node * node_aff(Node * id, Node * expr){
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    return NULL;
  }
  node->type = AFF;
  node->left = id;
  node->right = expr;
  return node;
}

Node * node_inst(Node * instruction){
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    return NULL;
  }
  node->type = INST;
  node->left = instruction;
  node->right = NULL;
  return node;
}

Node * node_if(Node * inst){
  if_args * args = malloc(sizeof(*args));
  if(args == NULL){
    return NULL;
  }
  args->value = 0;
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    free(args);
    return NULL;
  }
  node->type = IF;
  node->left = inst;
  node->right = NULL;
  node->if_args = args;
  return node;
}

void node_dispose(Node **nptr){
  if(*nptr == NULL){
    return;
  }
  switch((*nptr)->type){
    case ID : 
    case FUN :
    case CALL :
      id_args_dispose(&((*nptr)->id_args));
      break;
    case OPER : 
      free(((*nptr)->op_args));
      break;
    case IF :
    case ELSE :
      free((*nptr)->if_args);
      break;
    default:
      break;
  };
  free(*nptr);
  *nptr = NULL;
}

void node_fun_dispose(Node **nptr, hashtable *ht){
  if(*nptr == NULL){
    return;
  }
  if((*nptr)->type == FUN){
    llist * l = hashtable_search(ht, (*nptr)->id_args->identifier);
    llist_dispose(&l);
    node_dispose(nptr);
  }
  *nptr = NULL;
}

Node * node_ret(Node * expr){
  Node * node = malloc(sizeof(*node));
  if(node == NULL){
    return NULL;
  }
  node->type = RET;
  node->left = expr;
  node->right = NULL;
  return node;
}

// AFFICHAGE (partie du code réservé à l'affichage en code assembleur des 
// noeuds)

int nidcmp(Node * x, Node * y){
  if(x->type != ID || y->type != ID){
    return -1;
  }
  return strcmp(x->id_args->identifier, y->id_args->identifier);
}

void pint(int * value){
  printf("%d", *value);
}

void node_print_loc(Node * node){
  if(node != NULL && node->type == ID && node->id_args->type == LOC_ID){
    ASM_PUSH(0);
  }
}

void node_print_asm(Node * node, hashtable * ht, char * fname){
  if(node == NULL){
    return;
  }
  llist * l;
  if(strlen(fname) == 0 && node->type == CALL){
    l = hashtable_search(ht, node->id_args->identifier);
  } else {
    l = hashtable_search(ht, fname);
  }
  switch(node->type){
  case VALUE :
    ASM_PUSH(node->value);
    break;
  case OPER :
    switch(node->op_args->type){
        case OP_ADD:
        ASM_OPER("add");
        break;
        case OP_SUB:
        ASM_OPER("sub");
        break;
        case OP_MUL:
        ASM_OPER("mul");
        break;
        case OP_DIV : 
        ASM_OPER_ERR("div", DIV_ZERO_NAME);
        break;
        case OP_EQ : 
        ASM_CALL(EQ_NAME);
        break;
        case OP_NE : 
        ASM_CALL(NE_NAME);
        break;
        case OP_LT : 
        ASM_CALL(LT_NAME);
        break;
        case OP_GT : 
        ASM_CALL(GT_NAME);
        break;
        case OP_LE : 
        ASM_CALL(LE_NAME);
        break;
        case OP_GE : 
        ASM_CALL(GE_NAME);
        break;
        case OP_AND : 
        ASM_OPER("and");
        break;
        case OP_OR : 
        ASM_OPER("or");
        break;
        case OP_NOT : 
        ASM_CALL_ON_ONE(EQ_NAME, 0);
        break;
        default:
        break;
      }
    break;
  case AFF :
    STORE_IN_VAR(
        llist_search_number(l, node->left,(int (*)(void *, void *))nidcmp)
    );
    break;
  case ID : 
    switch(node->id_args->type){
        case FUN_ID : 
        STORE_IN_VAR(l->length);
        printf("\tret\n");
        break;
        case LOC_ID : 
        case ARGS_ID :
        LOAD_FROM_VAR(
          llist_search_number(l, node, (int (*)(void *, void *)) nidcmp)
        );
        break;
        default:
        break;
      }
    break;
  case FUN :
    break;
  case CALL :
    l = hashtable_search(ht, node->id_args->identifier);
    if(node->left == NULL){
        ASM_PUSH(0);
        llist_map(l,(void (*)(void *)) node_print_loc);
    }
    ASM_CALL_FUN(node->id_args->identifier);
    SUB_SP(l->length);
    if(strcmp(fname, "") == 0){
      ASM_PRINT();
    }
    break;
  case RET :
    STORE_IN_VAR(l->length);
    FUN_FOOTER();
    break;
  default:
    break;
  }
}


int node_print_fun_asm(Node * root, hashtable * ht){
  if(root == NULL || root->type != FUN){
    return 1;
  }
  char * fname = root->id_args->identifier;
  if(strlen(fname) != 0){
    FUN_HEADER(fname);
  }
  // pile des noeuds
  stack * s = stack_empty(); 
  if(s == NULL){
    return - 1;
  }
  // pile des visités
  stack * v = stack_empty();
  if(v == NULL){
    stack_dispose(&s);
    return -1;
  }
  // pile des if 
  llist * ifs = llist_empty();
  if(ifs == NULL){
    stack_dispose(&s);
    stack_dispose(&v);
    return -1;
  }
  int * ifcount = malloc(sizeof(*ifcount));
  if(ifcount == NULL){
    stack_dispose(&s);
    stack_dispose(&v);
    llist_dispose(&ifs);
    return -1;
  }
  llist_add(ifs, ifcount);
  *ifcount = 0;

  Node * n = root;
  int * i = malloc(sizeof(*i));
  if(i == NULL){
    stack_dispose(&s);
    stack_dispose(&v);
    free(ifcount);
    llist_dispose(&ifs);
    return -1;
  }
  *i = 0;

  while(n != NULL){
    if(n->left != NULL && *i < 1){
      // FIRST ENCOUNTER
      if(n->type == CALL){
        ASM_PUSH(0);
        llist_map(hashtable_search(ht, n->id_args->identifier)
                  ,(void (*)(void *)) node_print_loc);
      }
      if(n->type == ELSE){
        ifcount = llist_remove(ifs);
        free(ifcount);
        ifcount = ifs->head->ref;

        *ifcount += 1;
        printf("\tconst ax,i");
        llist_map(ifs, (void (*)(void *))pint);
        printf("%s", fname);
        printf("\n");
        printf("\tjmp ax\n");

        *ifcount -= 1;
        printf(":i");
        llist_map(ifs, (void (*)(void *))pint);
        printf("%s", fname);
        printf("\n");
        *ifcount += 1;
        ifcount = malloc(sizeof(*ifcount));
        *ifcount = 0;
        llist_add(ifs, ifcount);
      }
      if(n->type == WHILE){
        printf(":i");
        *ifcount += 1;
        llist_map(ifs, (void (*)(void *))pint);
        printf("%s", fname);
        *ifcount -= 1;
        printf("\n");
      }
      *i = 1;
      stack_push(s, n);
      stack_push(v, i);
      n = n->left;
      i = malloc(sizeof(*i));
      if(i == NULL){
        stack_dispose(&s);
        stack_dispose(&v);
        free(ifcount);
        llist_dispose(&ifs);
        return -1;
      }
      *i = 0;
    } else {
      if(n->right != NULL && *i < 2){
        // SECOND ENCOUNTER
        if(n->type == COND){
          printf("\tconst cx,i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          CHECK_COND();
          ifcount = malloc(sizeof(*ifcount));
          *ifcount = 0;
          llist_add(ifs, ifcount);
        }
        else if(n->type == IF){
          ifcount = llist_remove(ifs);
          free(ifcount);
          ifcount = ifs->head->ref;
          printf(":i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          *ifcount += 1;
        } 
        if(n->type == ELSE){
          printf(":i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
        }
        if(n->type == WHILE){
          ifcount = llist_remove(ifs);
          free(ifcount);
          ifcount = ifs->head->ref;
          printf("\tconst ax,i");
          *ifcount += 1;
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          *ifcount -= 1;
          printf("\tjmp ax\n");
          printf(":i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          *ifcount += 2;
        }
        *i = 2;
        stack_push(s, n);
        stack_push(v, i);
        n = n->right;
        i = malloc(sizeof(*i));
        if(i == NULL){
          stack_dispose(&s);
          stack_dispose(&v);
          free(ifcount);
          llist_dispose(&ifs);
          return -1;
        }
        *i = 0;
      } else {
        // LAST ENCOUNTER
        if(n->type == IF && n->right == NULL){
          ifcount = llist_remove(ifs);
          free(ifcount);
          ifcount = ifs->head->ref;
          printf(":i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          *ifcount += 1;
        }
        if(n->type == WHILE && n->right == NULL){
          ifcount = llist_remove(ifs);
          free(ifcount);
          ifcount = ifs->head->ref;
          printf("\tconst ax,i");
          *ifcount += 1;
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          *ifcount -= 1;
          printf("\tjmp ax\n");
          printf(":i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
        }
        if(n->type == COND && n->right == NULL){
          printf("\tconst cx,i");
          llist_map(ifs, (void (*)(void *))pint);
          printf("%s", fname);
          printf("\n");
          CHECK_COND();

          ifcount = malloc(sizeof(*ifcount));
          *ifcount = 0;
          llist_add(ifs, ifcount);
        }
        node_print_asm(n, ht, fname);
        free(i);
        n = stack_pop(s);
        i = stack_pop(v);
      }
    }
  }
  stack_dispose(&s);
  stack_dispose(&v);
  free(ifcount);
  llist_dispose(&ifs);
  return 1;
}

int count_args(Node * node, int * acc){
  if(node->type == ID && node->id_args->type == ARGS_ID){
    *acc += 1;
  }
  return 1;
}

int is_type_defined(Node * node, int * acc){
  *acc += 1;
  if((node->type == ID) && (node->id_args->type == ARGS_ID
     || node->id_args->type == LOC_ID) 
    && node->id_args->v_type == UNKNOW_T){
    return -1;
  }
  return 1;
}
