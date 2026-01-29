// lib.cpp

#include "lib.hpp"

auto sum(float a, float b) -> float { return a + b; }

auto power(int base, int exp) -> long {
  long result{base};
  for (long i = 1; i < exp; i++) {
    result *= base;
  }
  return result;
}
