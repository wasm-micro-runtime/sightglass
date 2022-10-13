#include <stdio.h>

#ifndef __ZEPHYR__
// __attribute__ ((__optimize__ ("-fno-tree-loop-distribute-patterns")))
// void *memset(void *s, int c, size_t n)
// {
//     if (s) {
//         unsigned char *p = s, *p_end = p + n;
//         unsigned char v = (unsigned char)c;
//         while (p < p_end)
//             *p++ = v;
//     }
//     return s;
// }

__attribute__ ((__optimize__ ("-fno-tree-loop-distribute-patterns")))
void *memmove(void *dest, const void *src, size_t n)
{
    char *d = dest;
    const char *s = src;
    if (d < s) {
        while (n--)
            *d++ = *s++;
    }
    else {
        const char *lasts = s + (n-1);
        char *lastd = d + (n-1);
        while (n--)
            *lastd-- = *lasts--;
    }
    return dest;
}
#endif
