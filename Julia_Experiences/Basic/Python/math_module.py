# -*- coding: utf-8 -*-
# math_module.py

import numpy as np


def sum_squares(n:int) -> float:
    result = 0.0
    for i in range(1, n + 1):
        result += float(i)**2
    return result

def sum_squares_np(n:int) -> float:
    return np.sum(np.arange(1, n + 1, dtype=np.float64)**2)

if __name__ == '__main__':
    assert sum_squares(2)  == 5
    assert sum_squares(10) == 385
    assert sum_squares_np(10) == 385
