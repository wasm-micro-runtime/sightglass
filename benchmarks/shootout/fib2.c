
#include "sightglass.h"

typedef struct Fib2Ctx_ {
    unsigned long n;
    unsigned long res;
} Fib2Ctx;

void
fib2_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static Fib2Ctx ctx;
#if defined(STM32)
    ctx.n = 30;
#elif defined(ESP32)
    ctx.n = 26;
#elif !defined(TEST_INTERPRETER)
    ctx.n = 42;
#else
    ctx.n = 38;
#endif

    *ctx_p = (void *) &ctx;
}

static unsigned long
fib2(unsigned long n)
{
    if (n < 2) {
        return 1;
    }
    return fib2(n - 2) + fib2(n - 1);
}

void
fib2_body(void *ctx_)
{
    Fib2Ctx *ctx = (Fib2Ctx *) ctx_;

    ctx->res = fib2(ctx->n);
    BLACK_BOX(ctx->res);
}
