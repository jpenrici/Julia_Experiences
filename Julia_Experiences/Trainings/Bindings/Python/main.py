# -*- coding: utf-8 -*-
# main.py

import time

from juliacall import Main as jl

import math_module
jl.include("math_module.jl")
from juliacall import *

def sum_square_jl(n : int) -> None:
  result = math_module.sum_squares(n)
  print(f"n = {n}, result = {result}")


def test() -> None:
  sum_square_jl(2)
  sum_square_jl(10)


def main() -> None:
  print("Benchmarking Julia function from Python:")

  n = 10**6

  start = time.perf_counter()
  result = math_module.sum_squares(n)
  end = time.perf_counter()

  print(f"Julia via Python took: {end - start:.6f} seconds")


if __name__ == '__main__':
  test()
  main()
