
#include <sightglass.h>

#include <assert.h>
#include <stdlib.h>

#ifdef STM32
#  define LENGTH 100
#elif defined(ESP32)
#  define LENGTH 100
#elif !defined(TEST_INTERPRETER)
#  define LENGTH 300000
#else
#  define LENGTH 15000
#endif

#define SIZE 20

#ifdef STM32
#  define BUF_LEN 1024 * 10
#elif defined(ESP32)
#  define BUF_LEN 1024 * 10
#else
#  define BUF_LEN 1024 * 100
#endif

static char buf[BUF_LEN] = { 0 };
static char *p = buf;

static int **
mkmatrix(int rows, int cols)
{
    //int **m = calloc(rows, sizeof(int *));
    //assert(m != NULL);

    int **m = (int**)p;
    p += rows * sizeof(int *);

    int i, j, count = 1;
    for (i = 0; i < rows; i++) {
        //m[i] = calloc(cols, sizeof(int));
        //assert(m[i] != NULL);
        m[i] = (int*)p;
        p += cols * sizeof(int);
        for (j = 0; j < cols; j++) {
            m[i][j] = count++;
        }
    }
    return m;
}

static void
freematrix(int rows, int **m)
{
    /*
    while (--rows > -1) {
        free(m[rows]);
    }
    free(m);
    */
}

static int **
mmult(int rows, int cols, int **m1, int **m2, int **m3)
{
    int i, j, k, val;

    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols; j++) {
            val = 0;
            for (k = 0; k < cols; k++) {
                val += m1[i][k] * m2[k][j];
            }
            m3[i][j] = val;
        }
    }
    return m3;
}

typedef struct MatrixCtx_ {
    int **m1, **m2, **mm;
    int   rows;
    int   cols;
    int   n;
    int   res;
} MatrixCtx;

void
matrix_setup(void *global_ctx, void **ctx_p)
{
    (void) global_ctx;

    static MatrixCtx ctx;
    ctx.rows = SIZE;
    ctx.cols = SIZE;
    ctx.n    = LENGTH;
    ctx.m1   = mkmatrix(ctx.rows, ctx.cols);
    ctx.m2   = mkmatrix(ctx.rows, ctx.cols);
    ctx.mm   = mkmatrix(ctx.rows, ctx.cols);
    //assert(ctx.m1 != NULL && ctx.m2 != NULL && ctx.mm != NULL);

    *ctx_p = (void *) &ctx;
}

void
matrix_teardown(void *ctx_)
{
    MatrixCtx *ctx = (MatrixCtx *) ctx_;

    freematrix(ctx->rows, ctx->m1);
    freematrix(ctx->rows, ctx->m2);
    freematrix(ctx->rows, ctx->mm);
}

void
matrix_body(void *ctx_)
{
    MatrixCtx *ctx = (MatrixCtx *) ctx_;

    int i;
    for (i = 0; i < ctx->n; i++) {
        ctx->mm = mmult(ctx->rows, ctx->cols, ctx->m1, ctx->m2, ctx->mm);
    }
    ctx->res = ctx->mm[0][0] + ctx->mm[2][3] + ctx->mm[3][2] + ctx->mm[4][4];
    BLACK_BOX(ctx->res);
}
