#ifndef _TIME_H
#define _TIME_H

#ifdef __cplusplus
extern "C" {
#endif

#define CLOCK_MONOTONIC 1

typedef long int time_t;

typedef int clockid_t;

struct timespec {
    time_t tv_sec;
    long tv_nsec;
};

int
clock_gettime(clockid_t clock_id, struct timespec *tp);

int printf(const char *format, ...);

#ifdef __cplusplus
}
#endif

#endif
