! app/calc.f90
! Basic template for interoperability with C++ and Julia.

module dot_product_mod
   use, intrinsic :: iso_c_binding, only: c_double, c_int, c_ptr, c_f_pointer

   implicit none

contains

   ! Name of the function to see in C.
   function dot_product_fortran(n, vector1_ptr, vector2_ptr) &
      bind(C, name='dot_product_fortran') &
      result(result_value)

      integer(c_int), value :: n
      type(c_ptr), value :: vector1_ptr, vector2_ptr
      real(c_double) :: result_value

      real(c_double), pointer :: vector1(:), vector2(:)

      ! Relating C pointers to Fortran arrays
      call c_f_pointer(vector1_ptr, vector1, shape=[n])
      call c_f_pointer(vector2_ptr, vector2, shape=[n])

      ! Dot product (scalar product)
      result_value = sum(vector1*vector2)

   end function dot_product_fortran

end module dot_product_mod
