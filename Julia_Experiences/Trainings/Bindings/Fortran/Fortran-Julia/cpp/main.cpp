// cpp/main.cpp

#include <numeric>
#include <print>
#include <vector>

#include "calc.hpp"

auto main() -> int {

  const int N = 4;
  std::vector<double> vector1 = {1.0, 2.0, 3.0, 4.0};
  std::vector<double> vector2 = {5.0, 6.0, 7.0, 8.0};

  double result_fortran =
      dot_product_fortran(N, vector1.data(), vector2.data());

  double expected_result =
      std::inner_product(vector1.begin(), vector1.end(), vector2.begin(), 0.0);

  std::println("Fortran result: {}", result_fortran);
  std::println("C++ result: {}", expected_result);

  return 0;
}
