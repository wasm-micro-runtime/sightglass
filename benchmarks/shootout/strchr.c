
#include <sightglass.h>

//#include <assert.h>
#include <stdlib.h>
#include <string.h>

#define STR_SIZE 500000
#ifndef TEST_INTERPRETER
#define ITERATIONS 1000
#else
#define ITERATIONS 400
#endif

typedef struct StrchrCtx_ {
    char * str;
    size_t str_size;
    size_t ret;
} StrchrCtx;

static char str_buf[STR_SIZE] = { 0 };

void
strchr_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static StrchrCtx ctx;
    ctx.str_size = STR_SIZE;

    *ctx_p = (void *) &ctx;
}

char *my_strchr(const char *s, int c)
{
    unsigned char ch = (unsigned char)c, ch1;
    unsigned char *p = (unsigned char*)s;

    if (!s)
        return NULL;

    while ((ch1 = *p++) != '\0')
        if (ch1 == ch)
            return (char*)p - 1;

    return NULL;
}

void
strchr_body(void *ctx_)
{
    StrchrCtx *ctx = (StrchrCtx *) ctx_;

    char * str;
    size_t ret = (size_t) 0U;
    int    i;

    ctx->str = str_buf;//malloc(ctx->str_size);
    //assert(ctx->str != NULL);
    str = ctx->str;

    //assert(ctx->str_size >= 2U);
    memset(str, 'x', ctx->str_size);
    str[ctx->str_size - 1U] = 0;
    str[500] = 'A';
    str[1000] = 'A';

    for (i = 0; i < ITERATIONS * 1000; i++) {
        BLACK_BOX(str);
        ret += (my_strchr(str, 'A') != NULL);
    }

    //free(str);
    BLACK_BOX(ret);
    ctx->ret = ret;
}
