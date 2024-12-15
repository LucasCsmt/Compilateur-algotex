%{
    #include <stdio.h>    
    #include <stdlib.h>
    #include "stt.h"
    #include "util.h"
    #include "hashtable.h"

    int yylex();
    void yyerror(const char *err);
    Node * root;
    llist * funlist;
    char * current_fun;
    Node * current_type;
    hashtable * ht;
    llist * holdall;
%}
%union{
  Node * node;
  llist * list;
}
%type<node> MAIN
%type<node> INST
%type<node> TIF
%type<node> TWHILE
%type<node> TDOFORI
%type<node> EXPR
%type<node> EXPR_LIST
%type<node> AFF
%type FUN
%type<list> ARGS
%type<node> TCALL
// INTEGER
%token<node> VAL
// ID
%token<node> SYMB
%token DOWHILE
%token DOFORI
%token DIF
%token DELSE
%token FI
%token OD
%token SET
%token RETURN
%token ALGO
%token EALGO
%token FCALL

// BOOLEAN
%token TRUE
%token FALSE
%token AND      // AND
%token OR       // OR

    // Comparaisons
%token EQ       // EQUAL
%token NE       // NOT EQUAL
%token NOT      // NOT
%token LE       // LESS THAN OR EQUAL
%token GE       // GREATER THAN OR EQUAL
%token LT       // LESS THAN
%token GT       // GREATER THAN

%start MAIN

%left OR
%left AND
%left '=' NE
%left LE GE LT GT
%left '+' '-'
%left '*' '/'
%left NOT
%%
  MAIN : 
    FUN {
      $$ = NULL;
    }
    | TCALL MAIN {
      $$ = node_inst($1);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->right = $2;
      root->left = $$;
    }
    | {
      $$ = NULL;
    }
  
  FUN :
    ALGO '{' SYMB {
      if(hashtable_search(ht, $3->id_args->identifier) != NULL){
        fprintf(stderr, "function <%s> is already defined\n", 
          $3->id_args->identifier);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      current_fun = $3->id_args->identifier;
      current_type = node_id("", RET_ID);
      if(current_type == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, current_type);
      current_type->id_args->v_type = UNKNOW_T;
    }
    '}' ARGS {
      $6 = llist_reverse(&$6);
      if(hashtable_add(ht, current_fun, $6) == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        return EXIT_FAILURE;
      }
    } INST {
      llist * l = hashtable_search(ht, current_fun);
      l = llist_reverse(&l);
      int * acc = malloc(sizeof(*acc));
      if(acc == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      Node * n;
      *acc = 0;
      if(llist_map2(l, (int(*)(void *, void *)) is_type_defined, acc) == -1){
        fprintf(stderr,
          "ERROR : at least one var have no type defined in function <%s>\n",
          current_fun);
        free(acc);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      free(acc);
      llist_add(l, current_type);
      hashtable_add(ht, current_fun, l);
      n = $8;
      int r = 0;
      CONTAINING_RETURN_FOR_ALL_CASES(n, r);
      if(r != 1){
        fprintf(stderr, 
          "ERROR : a case without return exist in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      r = 0;
      n = $8;
      CHECK_END_OF_INST(EFUN, n, r); 
      if(r == 0){
        fprintf(stderr, 
          "ERROR : \\begin{algo} bloc must be closed by \\end{algo} in"
          "function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      if(funlist == NULL){
        funlist = llist_empty();
      }
      $3->type = FUN;
      $3->left = $8;
      $3->id_args->type = FUN_ID;
      llist_add(funlist, $3);
      current_fun = "";
    } MAIN 

  ARGS : 
    '{' '}' {
      $$ = llist_empty();
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    | '{' SYMB {
      $$ = llist_empty();
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $2->id_args->type = ARGS_ID;
      llist_add($$, $2);
      llist_add(holdall, $2);
    }
    | ARGS ',' SYMB {
      $$ = $1;
      $3->id_args->type = ARGS_ID;
      llist_add($$, $3);
      llist_add(holdall, $3);
    }
    | ARGS '}' {
      $$ = $1;
    }

  INST :
    EALGO {
      $$ = node_inst(NULL);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->type = EFUN;
    }
    | FI {
      $$ = node_inst(NULL);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->type = EIF;
    }
    | OD {
      $$ = node_inst(NULL);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->type = EWHILE;
    }
    | DELSE INST {
      $$ = node_if($2);
      llist_add(holdall, $$);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $$->type = ELSE;
      Node * n = $2;
      int r = 0;
      CONTAINING_RETURN_FOR_ALL_CASES(n, r);
      if(r != 1){
        $$->if_args->value = 0;
      } else {
        $$->if_args->value = 1;
      }
      if(r != 1){
        $$->if_args->value = 0;
      } else {
        $$->if_args->value = 1;
      }
    }
    | AFF INST {
      $$ = node_inst($1);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->right = $2;
    }
    | TIF INST{
      $$ = node_if($1);
      llist_add(holdall, $$);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $$->right = $2;
      Node * n = $1->right;
      int r = 0;
      while(n != NULL){
        if(n->type == IF && n->if_args->value == 1){
          r = 2;
        }
        if(n->type == RET || 
          (n->type == INST && n->left->type == RET)){
          r = 2;
        }
        if(n->type == ELSE){
          if(n->if_args->value == 1 && r == 2){
            r = 1;
            break;
          } else {
            r = 0;
            break;
          }
        }
        n = n->right;
      }
      if(r != 1){
        $$->if_args->value = 0;
      } else {
        $$->if_args->value = 1;
      }
      r = 0;
      n = $1->right;
      CHECK_END_OF_INST(EIF, n, r); 
    }
    | TWHILE INST { 
      $$ = node_inst($1);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->right = $2;
      $$->type = WHILE;
    }
    | TDOFORI INST {
      $$ = $1; 
      $1->right->right = $2;
    }
    | RETURN '{' EXPR '}' INST {
      v_type vt;
      if($3->type == OPER){
        vt = $3->op_args->v_type; 
      }
      else if($3->type == ID || $3->type == CALL){
        vt = $3->id_args->v_type; 
      } else {  
        vt = INT_T;
      }
      if(current_type->id_args->v_type == UNKNOW_T){
        current_type->id_args->v_type = vt;
      } else if(current_type->id_args->v_type != vt){
        fprintf(stderr, 
          "ERROR : return have different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $$ = node_ret($3);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      if($5 != NULL){
        if($5->type == ELSE
            || $5->type == EWHILE
            || $5->type == EFUN
            || $5->type == EIF){
          $$ = node_inst($$);
          if($$ == NULL){
            perror("malloc");
            llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
            llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                                node_fun_dispose, ht);
            hashtable_dispose(&ht);
            exit(EXIT_FAILURE);
          }
          llist_add(holdall, $$);
          $$->right = $5;
        } else {
          fprintf(stderr, 
          "WARNING : code after return in function <%s> that will never be"
          "executed\n", current_fun);
        }
      }
    }

  TIF : 
    DIF '{' EXPR '}' INST{
      if(($3->type == OPER && $3->op_args->v_type != BOOL_T)
      || (($3->type == CALL || $3->type == ID) 
      && $3->id_args->v_type != BOOL_T)
      || ($3->type == VALUE)){
        fprintf(stderr, 
          "ERROR : IF condition must be of type BOOL in function "
          "<%s>\n", current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $$ = node_inst($3);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->type = COND;
      $$->right = $5;
    }

  TWHILE : 
    DOWHILE '{' EXPR '}' INST {
      if(($3->type == OPER && $3->op_args->v_type != BOOL_T)
      || (($3->type == CALL || $3->type == ID) 
      && $3->id_args->v_type != BOOL_T) ||
        ($3->type == VALUE)){
        fprintf(stderr, 
          "ERROR : DOWHILE stop condition must be of type BOOL in function "
          "<%s>\n", current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      $$ = node_inst($3);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->type = COND;
      $$->right = $5;
    }
  TDOFORI : 
    DOFORI '{' SYMB '}' {
      llist_add(holdall, $3);
      llist * l = hashtable_search(ht, current_fun);
      Node * n = llist_search(l, $3, (int (*)(void *, void *)) nidcmp);
      if(n == NULL){
        n = node_id($3->id_args->identifier, LOC_ID);
        if(n == NULL){
          perror("malloc");
          llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
          llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                              node_fun_dispose, ht);
          hashtable_dispose(&ht);
          exit(EXIT_FAILURE);
        }
        llist_add(holdall, n);
        n->id_args->v_type = INT_T;
        $3->id_args->v_type = INT_T;
        llist_add(l, n);
      } else {
        if(n->id_args->v_type == UNKNOW_T){
          n->id_args->v_type = INT_T;
        } else {
          if(n->id_args->v_type != INT_T){
            fprintf(stderr, 
            "ERROR : bad type for var <%s> in function <%s>\n",
              n->id_args->identifier, current_fun);
            llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
            llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                                node_fun_dispose, ht);
            hashtable_dispose(&ht);
            exit(EXIT_FAILURE);
          }
        }
      }
    } '{' EXPR '}' '{' EXPR '}' {
      llist * l = hashtable_search(ht, current_fun);
      Node * n = llist_search(l, $3, (int (*)(void *, void *)) nidcmp);
      v_type vt;
      switch($7->type){
        case OPER : 
        vt = $7->op_args->v_type;
        break;
        case ID :
        n = llist_search(l, $7, (int (*)(void *, void *))nidcmp);
        if(n == NULL){
          fprintf(stderr, 
            "ERROR : var <%s> is not defined in function <%s>",
            $7->id_args->identifier, current_fun);
            llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
            llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                                node_fun_dispose, ht);
            hashtable_dispose(&ht);
            exit(EXIT_FAILURE);
        }
        if(n->id_args->v_type == UNKNOW_T){
          n->id_args->v_type = INT_T;
          vt = INT_T;
        } else {
          vt = n->id_args->v_type;
        }
        break;
        case CALL : 
        vt = $7->id_args->v_type;
        break;
        default : 
        vt = INT_T;
        $10->id_args->v_type = INT_T;
        break;
      }
      if(vt != INT_T){
        fprintf(stderr, 
          "ERROR : DOFORI arguments must be of type INT in function "
          "<%s>\n", current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      switch($10->type){
        case OPER : 
        vt = $10->op_args->v_type;
        break;
        case ID :
        n = llist_search(l, $10, (int (*)(void *, void *))nidcmp);
        if(n == NULL){
          fprintf(stderr, 
            "ERROR : var <%s> is not defined in function <%s>",
            $10->id_args->identifier, current_fun);
            llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
            llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                                node_fun_dispose, ht);
            hashtable_dispose(&ht);
            exit(EXIT_FAILURE);
        }
        if(n->id_args->v_type == UNKNOW_T){
          n->id_args->v_type = INT_T;
          vt = INT_T;
        } else {
          vt = n->id_args->v_type;
        }
        break;
        case CALL : 
        vt = $10->id_args->v_type;
        break;
        default : 
        vt = INT_T;
        $10->id_args->v_type = INT_T;
        break;
      }
      if(vt != INT_T){
        fprintf(stderr, 
          "ERROR : DOFORI arguments must be of type INT in function "
          "<%s>\n", current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    } INST {
      llist * l = hashtable_search(ht, current_fun);
      Node * n = llist_search(l, $3, (int (*)(void *, void *)) nidcmp);
      // INITIALISATION 
      Node * aff = node_aff($3, $7);
      if(aff == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, aff);
      Node * i1 = node_inst(aff);
      if(i1 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, i1);

      // INCREMENT
      Node * v1 = node_value(1);
      if(v1 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, v1);
      Node * e1 = node_op(OP_ADD, n, v1);
      if(e1 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, e1);
      Node * incr = node_aff($3, e1);
      if(incr == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, incr);
      Node * i2 = node_inst(incr);
      if(i2 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, i2);

      // CONDITION
      Node * e2 = node_op(OP_LE, n, $10);
      if(e2 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, e2);
      Node * i3 = node_inst(e2);
      if(i3 == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, i3);
      i3->type = COND;
      i3->right = $13;
      
      Node * w = node_inst(i3);
      if(w == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, w);
      w->type = WHILE;

      n = $13;
      if(n == NULL){
        fprintf(stderr, 
          "ERROR : \\DOFORI must end with \\OD in function <%s>\n",
          current_fun);
        exit(EXIT_FAILURE);
      }
      if(n->type == EWHILE){
        i2->right = n; 
        i3->right = i2;
      } else {
        while(n->right != NULL && n->right->type != EWHILE){
          n = n->right;
        } 
        i2->right = n->right;
        n->right = i2;
      }
      i1->right = w;
      $$ = i1;
    }

  EXPR : 
  // ARITHMETIQUE
  EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, INT_T);
    }
  } '+' EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($4, INT_T);
    }
    ASSERT_OP_TYPE_INT($1, $4);
    $$ = node_op(OP_ADD, $1, $4);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = INT_T;
    llist_add(holdall, $$);
  }
  | EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, INT_T);
    }
  } '-' EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($4, INT_T);
    }
    ASSERT_OP_TYPE_INT($1, $4);
    $$ = node_op(OP_SUB, $1, $4);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = INT_T;
    llist_add(holdall, $$);
  }
  | EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, INT_T);
    }
  } '*' EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($4, INT_T);
    }
    ASSERT_OP_TYPE_INT($1, $4);
    $$ = node_op(OP_MUL, $1, $4);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = INT_T;
    llist_add(holdall, $$);
  }
  | EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, INT_T);
    }
  } '/' EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($4, INT_T);
    }
    ASSERT_OP_TYPE_INT($1, $4);
    $$ = node_op(OP_DIV, $1, $4);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = INT_T;
    llist_add(holdall, $$);
  }
  | VAL {
    $$ = $1;
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    llist_add(holdall, $$);
  }
  | '-' VAL {
    $$ = $2;
    $2->value = -$2->value;
    $$ = $2;
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    llist_add(holdall, $$);
  }
  // BOOL 
  | EXPR '=' EXPR { 
    $$ = node_op(OP_EQ, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR NE EXPR {
    $$ = node_op(OP_NE, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR LT EXPR {
    $$ = node_op(OP_LT, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR GT EXPR {
    $$ = node_op(OP_GT, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR LE EXPR {
    $$ = node_op(OP_LE, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR GE EXPR {
    $$ = node_op(OP_GE, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    v_type vt1;
    VTYPE_OF_NODE($1, vt1);
    v_type vt2;
    VTYPE_OF_NODE($3, vt2);
    if(vt1 == UNKNOW_T){
      SET_TYPE_OF_NODE($1, vt2);
    } else if(vt2 == UNKNOW_T){
      SET_TYPE_OF_NODE($3, vt1);
    } else {
      if(vt1 != vt2){
        fprintf(stderr, 
          "ERROR : comparaisons of two different type in function <%s>\n",
          current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR AND EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, BOOL_T);
      SET_ID_TYPE($3, BOOL_T);
    }
    ASSERT_OP_TYPE_BOOL($1, $3);
    $$ = node_op(OP_AND, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | EXPR OR EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($1, BOOL_T);
      SET_ID_TYPE($3, BOOL_T);
    }
    ASSERT_OP_TYPE_BOOL($1, $3);
    $$ = node_op(OP_OR, $1, $3);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | NOT EXPR {
    if(strcmp(current_fun, "") != 0){
      SET_ID_TYPE($2, BOOL_T);
    }
    $$ = node_op(OP_NOT, $2, NULL);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
  }
  | TRUE {
    Node * n = node_value(1);
    if(n == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$ = node_op(OP_BOOL, n, NULL);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
    llist_add(holdall, n);
  }
  | FALSE {
    Node * n = node_value(0);
    if(n == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$ = node_op(OP_BOOL, n, NULL);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    $$->op_args->v_type = BOOL_T;
    llist_add(holdall, $$);
    llist_add(holdall, n);
  }

  // AUTRE
  | SYMB {
    llist * args = hashtable_search(ht, current_fun);
    if(args == NULL){
      fprintf(stderr,
      "ERROR : function <%s> not defined\n",
      current_fun);
      exit(EXIT_FAILURE);
    }
    llist_add(holdall, $1);
    Node * n = llist_search(args, $1, (int(*)(void *, void *))nidcmp);
    if(n == NULL){
      fprintf(stderr, 
        "ERROR : var <%s> is not set in the function <%s>\n",
        $1->id_args->identifier, current_fun);
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
    }
    $$ = n;
  }
  | TCALL {
    $$ = $1;
    llist * l = hashtable_search(ht, $1->id_args->identifier);
    Node * n = l->head->ref;
    $$->id_args->v_type = n->id_args->v_type;
  }
  | '(' EXPR ')' {
    $$ = $2;
  }

  AFF : 
  SET '{' SYMB '}' '{' EXPR '}' {
    llist_add(holdall, $3);
    llist * l = hashtable_search(ht, current_fun);
    Node * n = llist_search(l, $3, (int (*)(void *, void *)) nidcmp);
    if(n == NULL){
      n = node_id($3->id_args->identifier, LOC_ID);
      if(n == NULL){
        perror("malloc"); 
        llist_dispose_map(&holdall, 
        (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, n);
      if($6->type == OPER){
        n->id_args->v_type = $6->op_args->v_type;
      } else if($6->type == CALL || $6->type == ID){
        n->id_args->v_type = $6->id_args->v_type;
      } else if($6->type == VALUE){
        n->id_args->v_type = INT_T;
      }
      llist_add(l, n);
    } else {
      if(n->id_args->v_type == UNKNOW_T){
        if($6->type == OPER){
          n->id_args->v_type = $6->op_args->v_type;
        } else if($6->type == ID || $6->type == CALL){
          n->id_args->v_type = $6->id_args->v_type;
        } else if($6->type == VALUE){
          n->id_args->v_type = INT_T;
        }
      } else {
        if(($6->type == OPER && $6->op_args->v_type != n->id_args->v_type)
        || (($6->type == ID || $6->type == CALL) &&
            $6->id_args->v_type != n->id_args->v_type)){
          fprintf(stderr, "ERROR : bad type for var <%s> in function <%s>\n",
            n->id_args->identifier, current_fun);
          llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
          llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                              node_fun_dispose, ht);
          hashtable_dispose(&ht);
          exit(EXIT_FAILURE);
        }
      }
    }
    $$ = node_aff($3, $6);
    if($$ == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    llist_add(holdall, $$);
  }
  
  EXPR_LIST : 
    '{' '}' {
      $$ = NULL;
    }
    | '{' EXPR_LIST {
      $$ = $2;
    }
    | EXPR ',' EXPR_LIST {
      $$ = node_inst($1);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
      $$->right = $3;
    }
    | EXPR '}' {
      $$ = node_inst($1);
      if($$ == NULL){
        perror("malloc");
        llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
        llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                            node_fun_dispose, ht);
        hashtable_dispose(&ht);
        exit(EXIT_FAILURE);
      }
      llist_add(holdall, $$);
    }

  TCALL : 
  FCALL '{' SYMB {
    llist_add(holdall, $3);
    llist * args;
    if((args = hashtable_search(ht, $3->id_args->identifier)) == NULL){
      fprintf(stderr,"ERROR : call of a non existant function <%s>\n", 
        $3->id_args->identifier);
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
  } '}' EXPR_LIST {
    llist * l = hashtable_search(ht, $3->id_args->identifier);
    int count = 0;
    Node * node = $6;
    Node * n;
    Node * arg;
    while(node != NULL){
      count += 1;
      if(node->type == INST){
        n = node->left; 
      } else {
        n = node;
      }
      if(strcmp(current_fun, $3->id_args->identifier) == 0){
        arg = llist_get_n(l, count - 1);
      } else {
        arg = llist_get_n(l, count);
      }
      if(n->type == OPER){
        if(n->op_args->v_type != arg->id_args->v_type){
          fprintf(stderr, 
          "ERROR : bad type of arg %d for the call to function <%s>\n",
          count, $3->id_args->identifier);
          llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
          llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                              node_fun_dispose, ht);
          hashtable_dispose(&ht);
          exit(EXIT_FAILURE);
        }
      } else if(n->type == ID || n->type == CALL){
        if(n->id_args->v_type != arg->id_args->v_type){
          fprintf(stderr, 
          "ERROR : bad type of arg %d for the call to function <%s>\n",
          count, $3->id_args->identifier);
          llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
          llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                              node_fun_dispose, ht);
          hashtable_dispose(&ht);
          exit(EXIT_FAILURE);
        }
      } else if(n->type == VALUE){
        if(arg->id_args->v_type != INT_T){
          fprintf(stderr, 
          "ERROR : bad type of arg %d for the call to function <%s>\n",
          count, $3->id_args->identifier);
          llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
          llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                              node_fun_dispose, ht);
          hashtable_dispose(&ht);
          exit(EXIT_FAILURE);
        }
      }
      node = node->right;
    }
    int * expect = malloc(sizeof(*expect));
    if(expect == NULL){
      perror("malloc");
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    *expect = 0;
    llist_map2(l, (int (*)(void *, void *))count_args, expect);
    if(*expect != count){
      fprintf(stderr, 
        "ERROR : too few/many argument for in call of function <%s>"
        " (got %d expect %d)\n"
      ,$3->id_args->identifier, count, *expect);
      free(expect);
      llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
      llist_dispose_map2(&funlist, (void (*)(void **, void *)) 
                          node_fun_dispose, ht);
      hashtable_dispose(&ht);
      exit(EXIT_FAILURE);
    }
    free(expect);
    $$ = $3;
    $$->type = CALL;
    $$->left = $6;
    llist * args = hashtable_search(ht, $3->id_args->identifier);
    $$->id_args->v_type = ((Node *)args->head->ref)->id_args->v_type;
  }

%%


int main(void){
    ht = hashtable_empty(compar, hashfun);
    holdall = llist_empty();
    root = node_id("", FUN_ID);
    if(root == NULL){
      perror("malloc");
      goto error;
    }
    if(llist_add(holdall, root) == NULL){
      goto error;
    };
    root->type = FUN;
    HEADER();
    yyparse();
    node_print_fun_asm(root, ht);
    FOOTER();
    NL_LABEL();
    if(llist_map2(funlist,
      (int(*)(void *, void *)) node_print_fun_asm, ht) == -1){
      fprintf(stderr, "ERROR : syntax tree's parsing error\n");
      goto error;
    }
    // Erreurs
    DIV_ZERO_LABEL();

    // Comparaisons
    EQ_LABELS(EQ_NAME, "cmp", TRUE_NAME, FALSE_NAME);
    EQ_LABELS(NE_NAME, "cmp", FALSE_NAME, TRUE_NAME);
    EQ_LABELS(LT_NAME, "sless", TRUE_NAME, FALSE_NAME);
    EQ_LABELS_2(GT_NAME, "sless", "cmp", FALSE_NAME, TRUE_NAME);
    EQ_LABELS(GE_NAME, "sless", FALSE_NAME, TRUE_NAME);
    EQ_LABELS_2(LE_NAME, "sless", "cmp", TRUE_NAME, FALSE_NAME);
    
    // Affectations
    AX_AFFECT_LABEL(TRUE_NAME, "1");
    AX_AFFECT_LABEL(FALSE_NAME, "0");
    END();

    // Libération des ressources
    llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
    llist_dispose_map2(&funlist, (void (*)(void **, void *)) node_fun_dispose, ht);
    hashtable_dispose(&ht);
    return EXIT_SUCCESS;
    error : 
    llist_dispose_map(&holdall, (void (*)(void **)) node_dispose);
    llist_dispose_map2(&funlist, (void (*)(void **, void *)) node_fun_dispose, ht);
    hashtable_dispose(&ht);
    exit(EXIT_FAILURE);
}

void yyerror(const char *err) {
    fprintf(stderr, "%s", err);
}
