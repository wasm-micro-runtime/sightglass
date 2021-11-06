
#include <sightglass.h>

#include <stdlib.h>

#ifdef STM32
#  define LENGTH 10
#elif defined(ESP32)
#  define LENGTH 2
#elif !defined(TEST_INTERPRETER)
#  define LENGTH 40
#else
#  define LENGTH 20
#endif

typedef struct NestedLoop2Ctx_ {
    int n;
    int x;
    int res;
} NestedLoop2Ctx;

void
nestedloop2_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static NestedLoop2Ctx ctx;
    ctx.n = LENGTH;
    ctx.x = 0;

    *ctx_p = (void *) &ctx;
}

void
nestedloop2_body(void *ctx_)
{
    NestedLoop2Ctx *ctx = (NestedLoop2Ctx *) ctx_;

    int n = ctx->n;
    int x = ctx->x;
    int a, b, c, d, e, f;

    for (a = 0; a < n; a++) {
        for (b = 1; b < n; b++) {
            for (c = 2; c < n; c++) {
                for (d = 3; d < n; d++) {
                    for (e = 4; e < n; e++) {
                        for (f = 5; f < n; f++) {
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
