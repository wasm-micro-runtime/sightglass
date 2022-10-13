import os
# import subprocess
# import multiprocessing
# from multiprocessing import Process
# from multiprocessing import Barrier

benchmarks = [
    "base64",
    "fib2",
    "gimli",
    "heapsort",
    "matrix",
    "memmove",
    "nestedloop",
    "nestedloop2",
    "nestedloop3",
    "random",
    "seqhash",
    "sieve",
    "strchr",
    "switch2",
]


# def run_command(cmd: str, barrier: Barrier, ignore_return_code: bool = False):

#     p = subprocess.call(cmd, shell=True, stdout=subprocess.PIPE)
#     barrier.wait()

#     if not ignore_return_code and p != 0:
#         return False

#     return True


def main():

    # cpu_number = multiprocessing.cpu_count()
    # print("host has {} cpu_number".format(cpu_number))

    # # os.environ
    # # some task run in parallel, but don't burn all cpu
    # barrier = Barrier(cpu_number / 2)

    # for benchmark in benchmarks:
    #     command = "./test_on_sgx.sh {bench} > {bench}.txt".format(bench=benchmark)
    #     subprocess(run_command, args=(command, barrier))
    #     barrier.wait()

    for benchmark in benchmarks:
        os.system("./test_on_sgx.sh {bench} > {bench}.txt".format(bench=benchmark))

    # barrier.wait()


if __name__ == "__main__":
    main()
