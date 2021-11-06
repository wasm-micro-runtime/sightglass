#include <sightglass.h>

#include <stdlib.h>
#include <stdint.h>

#ifdef STM32
#  define LENGTH 5000000
#elif defined(ESP32)
#  define LENGTH 1000000
#elif !defined(TEST_INTERPRETER)
#  define LENGTH 40000000
#else
#  define LENGTH 120000000
#endif

#define IA 3877
#define IC 29573
#define IM 139968

typedef struct RandomCtx_ {
    long   ia;
    long   ic;
    long   im;
    int    n;
    int64_t res;
} RandomCtx;

static inline int64_t
gen_random(int64_t max, long ia, long ic, long im)
{
    static long last = 42;

    last = (last * ia + ic) % im;
    return max * last / im;
}

void
random_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static RandomCtx ctx;
    ctx.ia = IA;
    ctx.ic = IC;
    ctx.im = IM;
    ctx.n  = LENGTH;

    *ctx_p = (void *) &ctx;
}

void
random_body(void *ctx_)
{
    RandomCtx *ctx = (RandomCtx *) ctx_;

    int n = ctx->n;
    while (n--) {
        gen_random(100, ctx->ia, ctx->ic, ctx->im);
    }
    ctx->res = gen_random(100, ctx->ia, ctx->ic, ctx->im);
    BLACK_BOX(ctx->res);
}
