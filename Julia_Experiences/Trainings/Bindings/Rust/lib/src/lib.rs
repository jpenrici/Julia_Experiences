// lib/src/lib.rs

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub unsafe extern "C" fn process_string(input: *const c_char) -> *mut c_char {

    if input.is_null() {
        return std::ptr::null_mut();
    }

    // Safely convert C pointer to Rust &str
    let c_str = unsafe { CStr::from_ptr(input) };
    let recipient = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => "invalid UTF-8",
    };

    let result = format!("{}", recipient);

    CString::new(result).unwrap().into_raw()
}

#[no_mangle]
pub unsafe extern "C" fn free_string(ptr: *mut c_char) {

    if ptr.is_null() { return; }
    unsafe {
        let _ = CString::from_raw(ptr);
    }

}
