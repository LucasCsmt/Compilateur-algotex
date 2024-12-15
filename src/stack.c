#include <stdio.h>
#include <stdlib.h>
#include "../include/stack.h"

stack * stack_empty(){
  stack * s = malloc(sizeof(*s));
  if(s == NULL){
    return NULL;
  }
  s->head = NULL;
  return s;
}

void * stack_push(stack * s, void * ref){
  if(s == NULL){
    return NULL;
  }
  scell * c = malloc(sizeof(*c));
  if(c == NULL){
    perror("malloc");
    return NULL;
  }
  c->ref = ref;
  c->next = s->head;
  s->head = c;
  return ref;
}

extern void * stack_pop(stack *s){
  if(s == NULL || s->head == NULL){
    return NULL;
  }
  scell * c = s->head;
  s->head = c->next;
  void * r = c->ref;
  free(c);
  return r;
}

void * stack_seek(stack *s){
  if(s == NULL){
    return NULL;
  }
  if(s->head == NULL){
    return NULL;
  }
  return s->head->ref;
}

extern void stack_dispose(stack ** sptr){
  if(*sptr == NULL){
    return;
  }
  while((*sptr)->head != NULL){
    stack_pop(*sptr);
  }
  free(*sptr);
  sptr = NULL;
}
