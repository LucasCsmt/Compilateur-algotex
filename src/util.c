#include "../include/util.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int int_from_string(char *str, int16_t *num){
    errno = 0;
    int k = strtol(str, NULL, 10);
    if (errno == ERANGE || k > INT16_MAX || k < INT16_MIN) {
        return -1;
    }
    *num = (int16_t) k;
    return 0;
}

size_t hashfun(const void *s) {
  size_t h = 0;
  for (const unsigned char *p = (const unsigned char *) s; *p != '\0'; ++p) {
    h = 37 * h + *p;
  }
  return h;
}

int compar(const void *a, const void *b){
    return strcmp(((char *) a), ((char *) b));
}

