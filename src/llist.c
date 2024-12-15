#include "../include/llist.h"
#include <stdlib.h>

llist * llist_empty(){
  llist * l = malloc(sizeof(*l));
  if(l == NULL){
    return NULL;
  }
  l->head = NULL;
  l->length = 0;
  return l;
}

void * llist_add(llist * l, void * ref){
  if(l == NULL){
    return NULL;
  }
  lcell * c = malloc(sizeof(*c));
  if(c == NULL){
    return NULL;
  }
  c->next = l->head;
  c->ref = ref;
  l->head = c;
  l->length += 1;
  return ref; 
}

void * llist_remove(llist * l){
  if(l == NULL){
    return NULL;
  }
  lcell * c = l->head;
  if(c == NULL){
    return NULL;
  }
  l->head = c->next;
  void * ref = c->ref;
  free(c);
  l->length -= 1;
  return ref;
}

llist * llist_reverse(llist ** lptr){
  if(lptr == NULL || *lptr == NULL){
    return NULL;
  } 
  llist * r = llist_empty();
  lcell * c = (*(lptr))->head;
  while(c != NULL){
    llist_add(r, c->ref);
    c = c->next;
  }
  llist_dispose(lptr);
  return r;
}

void llist_dispose(llist ** lptr){
  if(*lptr == NULL){
    return;
  }
  lcell * c = (*lptr)->head;
  while(c != NULL){
    (*lptr)->head = c->next;
    free(c);
    c = (*lptr)->head;
  }
  free(*lptr);
  lptr = NULL;
}
void llist_dispose_map(llist  ** lptr, void (*dispose)(void **)){
  if(*lptr == NULL){
    return;
  }
  lcell * c = (*lptr)->head;
  while(c != NULL){
    (*lptr)->head = c->next;
    dispose(&(c->ref));
    free(c);
    c = (*lptr)->head;
  }
  free(*lptr);
  lptr = NULL;
}
void llist_dispose_map2(llist  ** lptr, 
                        void (*dispose)(void **, void *), void * arg){
  if(*lptr == NULL){
    return;
  }
  lcell * c = (*lptr)->head;
  while(c != NULL){
    (*lptr)->head = c->next;
    dispose(&(c->ref), arg);
    free(c);
    c = (*lptr)->head;
  }
  free(*lptr);
  lptr = NULL;
}

void * llist_search(llist * l, void * ref, int (*comp)(void *, void *)){
  if(l == NULL){
    return NULL;
  }
  lcell * c = l->head;
  while(c != NULL){
    if(comp(c->ref, ref) == 0){
      return c->ref;
    }
    c = c->next;
  }
  return NULL;
}

void * llist_get_n(llist * l, int n){
  if(l == NULL){
    return NULL;
  }
  int count = 0;
  lcell * c = l->head;
  while(c != NULL && count < n){
    c = c->next;
    count += 1;
  }
  if(c == NULL){
    return NULL;
  }
  return c->ref;
}

int llist_search_number(llist * l, void * ref,
                        int (*comp)(void *, void *)){
  if(l == NULL){
    return -1;
  }
  int i = 0;
  lcell * c = l->head;
  while(c != NULL){
    if(comp(c->ref, ref) == 0){
      return i;
    }
    i += 1;
    c = c->next;
  }
  return -1;
}

void llist_map(llist * l, void (*fun)(void *)){
  if(l == NULL){
    return;
  }
  lcell * c = l->head;
  while(c != NULL){
    fun(c->ref);
    c = c->next;
  }
}

int llist_map2(llist * l, int(*fun)(void *, void *), void * arg){
  if(l == NULL){
    return -1;
  }
  lcell * c = l->head;
  while(c != NULL){
    if(fun(c->ref, arg) < 0){
      return -1;
    }
    c = c->next;
  }
  return 0;
}
