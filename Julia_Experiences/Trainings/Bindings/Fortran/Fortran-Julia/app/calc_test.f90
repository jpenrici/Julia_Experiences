! app/calc_test.f90
! Test executable to validate the dot_product_mod module.
!
! Compile:
!   gfortran -Wall -Wextra calc.f90 calc_test.f90 -o calc_test
! Run:
!   ./calc_test

program test_dot_product

    use dot_product_mod, only: dot_product_fortran
    use, intrinsic :: iso_c_binding, only: c_double, c_loc

    implicit none

    integer, parameter :: N = 4
    real(c_double), dimension(N), target :: vector1, vector2
    real(c_double) :: result_test, expected_result

    vector1 = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double /)
    vector2 = (/ 5.0_c_double, 6.0_c_double, 7.0_c_double, 8.0_c_double /)

    print '("Vector 1:", 4(F6.2))', vector1
    print '("Vector 2:", 4(F6.2))', vector2

    ! Calling the exported function (via C-binding)
    result_test = dot_product_fortran(N, c_loc(vector1(1)), c_loc(vector2(1)))

    ! Expected Result via Native Fortran
    expected_result = sum(vector1 * vector2)

    print '("Result (C-binding):", F6.2)', result_test
    print '("Result (Fortran):", F6.2)', expected_result

    ! Validate
    if (abs(result_test - expected_result) < 1e-9_c_double) then
        print '("SUCCESS! The Fortran module is working correctly.")'
    else
        print '("ERROR! The test result does not match the expected result.")'
    end if

end program test_dot_product
