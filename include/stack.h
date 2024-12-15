/** Stack permet la représentation de pile en C
 *  Cette structure ne contient que des pointeurs vers des références. Il  
 *  est donc de la responsabilité de celui qui utilise cette structure de  
 *  libérer les ressources associées à ces références.
 *
 *  Les fonctions qui utilisent des stack sont prévues pour fonctionner avec 
 *  des stack qui ont été généré avec la fonction d'initialisation 
 *  stack_empty().
*/
#ifndef __STACK_H__
#define __STACK_H__

typedef struct scell {
  struct scell * next;
  void * ref;
} scell;

typedef struct stack {
  scell * head;
} stack;

// stack_empty : alloue toutes les ressources nécessaire à la création d'une 
// pile. Renvoie la pile en cas de succès, NULL sinon.
extern stack * stack_empty();
// stack_push : prend en entré une pile et empile la reférence passé en 
// argument. Renvoie la référence en cas de succès, NULL sinon.
extern void * stack_push(stack * s, void * ref);
// stack_pop : prend en entré une pile et dépile une référence. Renvoie la 
// référence dépilé si la pile n'est pas vide, NULL sinon.
extern void * stack_pop(stack *s);
// stack_seek : prend en entré une pile et renvoie la référence en haut de la 
// pile si elle existe, NULL sinon.
extern void * stack_seek(stack *s);
// stack_dispose : libère toutes les ressources associées au pointeur de pile 
// passé en entré.
extern void stack_dispose(stack ** sptr);

#endif // !__STACK_H__
