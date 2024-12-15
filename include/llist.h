/** Linked List est une outil permettant de représenter en C des 
 * listes chaînées.
 *  Cette structure ne contient que des pointeurs vers des références. Il  
 *  est donc de la responsabilité de celui qui utilise cette structure de  
 *  libérer les ressources associées à ces références.
 *
 *  Les fonctions qui utilisent des llist sont prévues pour fonctionner avec 
 *  des llist qui ont été généré avec la fonction d'initialisation 
 *  llist_empty().
*/
#ifndef __LLIST_H__
#define __LLIST_H__

typedef struct lcell {
  struct lcell * next;
  void * ref;
} lcell;

typedef struct llist {
  lcell * head;
  int length;
} llist;

// llist_empty : alloue toutes les ressources nécessaire à la création d'une 
// liste vide. Renvoie un pointeur vers la liste en cas de succès, NULL 
// sinon.
extern llist * llist_empty();

// llist_add : prend en entré une liste l et ajoute à la liste la référence 
// pointé par ref. En cas de succès renvoie la référence, NULL sinon.
extern void * llist_add(llist * l, void * ref);

// llist_remove : pernd en entré une liste l et retire un élément de la liste 
// en tête. Si la liste est vide, renvoie NULL, sinon la référence.
extern void * llist_remove(llist * l);

// llist_reverse : prend en entré une liste l et renvoie la retournée de cette
// liste 
extern llist * llist_reverse(llist ** lptr);

// llist_dispose : libère toutes les ressources associées au pointeur de liste 
// lptr.
extern void llist_dispose(llist ** lptr);

// llist_dispose_map : Applique la fonction aux références pius libère 
// toutes les ressources associées au pointeur de liste lptr
extern void llist_dispose_map(llist  ** lptr, void (*dispose)(void **));

// llist_dispose_map2 : Applique la fonction aux références avec arg passé 
// en argument pius libère toutes les ressources associées au pointeur de 
// liste lptr
extern void llist_dispose_map2(llist  ** lptr, 
                              void (*dispose)(void **, void *), void * arg);

// llist_search : prend en entré une liste l et cherche dans cette liste une 
// cellule avec pour référence ref selon la fonction de comparaison comp. Si  
// l'élément est trouvé, celui-ci est renvoyé, sinon renvoie NULL.
extern void * llist_search(llist * l, void * ref, int (*comp)(void *, void *));

// llist_search_number : une fonction similaire à llist_search à la différence
// que cette fonction renvoie la position dans la liste de l'élément au lieu 
// de la cellule. Si l'élément n'est pas dans la liste, renvoie -1.
extern int llist_search_number(llist * l, void * ref,
                                   int (*comp)(void *, void *));

// llist_get_n : prend en entré une liste et renvoie la référence situé à 
// l'indice i s'elle existe, NULL sinon.
extern void * llist_get_n(llist * l, int n);

// llist_map : prend en entré une liste l et applique la fonction fun sur 
// chaque élément de la liste.
extern void llist_map(llist * l, void (*fun)(void *));

// llist_map2 : prend en entré une liste l et applique la fonction fun sur 
// chaque élément de la liste avec comme second attribut le paramètre 
// arg.
extern int llist_map2(llist * l, int(*fun)(void *, void *), void * arg);

#endif // !__LLIST_H__
