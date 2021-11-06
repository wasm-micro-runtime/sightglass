
#include <sightglass.h>

// #include <assert.h>
#include <stdlib.h>
#include <string.h>

#ifndef TEST_INTERPRETER
#define STR_SIZE 10000
#else
#define STR_SIZE 1000
#endif
#define ITERATIONS 200

typedef struct MemmoveCtx_ {
    char * str;
    size_t str_size;
    char   ret;
} MemmoveCtx;

void
memmove_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static MemmoveCtx ctx;
    ctx.str_size = STR_SIZE;

    *ctx_p = (void *) &ctx;
}

static char str_buf[STR_SIZE];

void
memmove_body(void *ctx_)
{
    MemmoveCtx *ctx = (MemmoveCtx *) ctx_;
    int         i;
    size_t      j;

    //ctx->str = calloc(ctx->str_size, (size_t) 1U);
    ctx->str = str_buf;
    // assert(ctx->str != NULL);

    for (i = 0; i < ITERATIONS; i++) {
        BLACK_BOX(ctx->str);
        for (j = (size_t) 0U; j < ctx->str_size - (size_t) 1U; j++) {
            memmove(&ctx->str[j], ctx->str, ctx->str_size - j);
        }
        for (j = (size_t) 0U; j < ctx->str_size - (size_t) 1U; j++) {
            memmove(ctx->str, &ctx->str[j], ctx->str_size - j);
        }
    }

    ctx->ret = ctx->str[0];
    BLACK_BOX(ctx->str);
    //free(ctx->str);
}
