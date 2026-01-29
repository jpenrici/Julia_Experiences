// test.cpp

#include "lib.hpp"

#include <print>
#include <string_view>

void view(std::string_view message, auto func, auto... args) {
  auto result = func(args...);
  std::println("{}...", message);
  std::println("Resultado: {}", result);
}

auto main() -> int {

  std::println("Test...");

  view("Use sum(float, float) -> float", sum, 14.5f, 5.5f); // 20
  view("Use pow(int, int) -> long", power, 5, 3);           // 125

  return 0;
}
