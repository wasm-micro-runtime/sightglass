import os

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


def main():

    report_file = "report.txt"

    # remove result from last run(if exist) and set table head
    os.system("rm {}".format(report_file))
    os.system(
        "echo \"\tsgx-native\tiwasm-aot\tiwasm-fast-jit\tiwasm-interp\tiwasm-fast-interp\" >> {}".format(
            report_file
        )
    )

    # start test
    os.system("./build_iwasm_sgx.sh")

    for benchmark in benchmarks:
        ret_code = os.system(
            "./test_on_sgx.sh {bench} {result_file}".format(
                bench=benchmark, result_file=report_file
            )
        )
        if ret_code:
            print(
                "test script ./test_on_sgx.sh {bench} exit with {ret_code} , check {bench}.txt for exact reason\n".format(
                    bench=benchmark, ret_code=ret_code
                )
            )

    os.system("./test_cleanup.sh")


if __name__ == "__main__":
    main()
