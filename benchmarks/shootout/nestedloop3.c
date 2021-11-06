
#include <sightglass.h>

#include <stdlib.h>

#ifndef TEST_INTERPRETER
#define LENGTH 110
#else
#define LENGTH 50
#endif

typedef struct NestedLoop3Ctx_ {
    int n;
    int x;
    int res;
} NestedLoop3Ctx;

void
nestedloop3_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static NestedLoop3Ctx ctx;
    ctx.n = LENGTH;
    ctx.x = 0;

    *ctx_p = (void *) &ctx;
}

void
nestedloop3_body(void *ctx_)
{
    NestedLoop3Ctx *ctx = (NestedLoop3Ctx *) ctx_;

    int n = ctx->n;
    int x = ctx->x;
    int a, b, c, d, e, f;

    for (a = 0; a < n; a++) {
        for (b = a; b < n; b++) {
            for (c = b; c < n; c++) {
                for (d = c; d < n; d++) {
                    for (e = d; e < n; e++) {
                        for (f = e; f < n; f++) {
                            x += (a + b + c) * (d + e) * (x + 10);
                        }
                    }
                }
            }
        }
    }

    BLACK_BOX(x);
    ctx->res = x;
}
