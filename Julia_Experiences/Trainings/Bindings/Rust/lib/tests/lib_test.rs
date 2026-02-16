// lib/tests/test.rs

use str_handler::{process_string, free_string};
use std::ffi::{CString, CStr};

#[test]
fn test_process_string_valid_input() {

    let input_str  = "Testing inside Rust";
    let input_cstr = CString::new(input_str).unwrap();

    unsafe {
        let raw_ptr =  process_string(input_cstr.as_ptr());

        assert!(!raw_ptr.is_null(), "Error: The returned pointer must not be null!");

        let result_cstr = CStr::from_ptr(raw_ptr);
        let result_str  = result_cstr.to_str().expect("Failed to convert to UTF-8");

        assert_eq!(result_str, input_str);

        free_string(raw_ptr);
    }
}

#[test]
fn test_process_string_null_input() {

    unsafe {
        let raw_ptr = process_string(std::ptr::null());

        assert!(raw_ptr.is_null(), "Error: Null input should return a null pointer.");

        free_string(raw_ptr);
    }
}
