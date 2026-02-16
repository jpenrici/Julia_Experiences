// cpp/calc.hpp

#ifndef CALC_WRAPPER_H
#define CALC_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

// Declaration of the function implemented in Fortran via Bind C.
double dot_product_fortran(int n, const double *vector1_ptr,
                           const double *vector2_ptr);

#ifdef __cplusplus
}
#endif

#endif // CALC_WRAPPER_H
