#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#ifdef DUMP_TIME_ELAPSE
#include <time.h>
#endif

static unsigned res = 0;

void set_res(void *x)
{
    res = *(unsigned*)x;
}

unsigned get_res()
{
    return res;
}

void ackermann_setup(void *global_ctx, void **ctx_p);
void ackermann_body(void *ctx);

unsigned app_main()
{
    void *p_ctx;

#ifdef DUMP_TIME_ELAPSE
    struct timespec ts_start, ts_end;
    uint64_t start, end;
    clock_gettime(CLOCK_MONOTONIC, &ts_start);
#endif

    ackermann_setup(NULL, &p_ctx);
    ackermann_body(p_ctx);

#ifdef DUMP_RESULT
    printf("##ret: %d\n", get_res());
#endif

#ifdef DUMP_TIME_ELAPSE
    clock_gettime(CLOCK_MONOTONIC, &ts_end);
    start = ts_start.tv_sec * 1000 + ts_start.tv_nsec / 1000000;
    end = ts_end.tv_sec * 1000 + ts_end.tv_nsec / 1000000;
    printf("time elapse: %u ms\n", (uint32_t)(end - start));
#endif

    return get_res();
}

#ifdef NOSTDLIB_MODE
void _start()
{
    app_main();
}
#endif

int main(int argc, char **argv)
{
    unsigned ret = app_main();

    return ret;
}

