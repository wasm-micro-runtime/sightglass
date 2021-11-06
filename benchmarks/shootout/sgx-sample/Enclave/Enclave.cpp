#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <stdbool.h>
#include "time.h"

#include "Enclave_t.h"

extern "C" {

int
printf(const char *message, ...)
{
    char msg[1024] = { 0 };
    va_list ap;

    va_start(ap, message);
    vsnprintf(msg, 1024, message, ap);
    va_end(ap);
    ocall_print(msg);

    return 0;
}

int
clock_gettime(clockid_t clock_id, struct timespec *tp)
{
    int ret = 0;

    if (ocall_clock_gettime(&ret, clock_id, (void *)tp, sizeof(struct timespec))
        != SGX_SUCCESS) {
        return -1;
    }

    return ret;
}

}

int main(int argc, char **argv);

void
ecall_main()
{
    main(0, NULL);
}
