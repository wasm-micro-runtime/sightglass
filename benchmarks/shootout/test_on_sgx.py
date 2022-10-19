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

    for benchmark in benchmarks:
        os.system("./test_on_sgx.sh {bench} > {bench}.txt".format(bench=benchmark))


if __name__ == "__main__":
    main()
