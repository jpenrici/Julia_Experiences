# main.jl

using Libdl

# --- Constants ---
const LIB_NAME = Sys.iswindows() ? "str_handler.dll" : "libstr_handler.so"
const LIB_RUST = abspath(joinpath(@__DIR__, "target", "release", LIB_NAME))

# --- Wrapper Module ---
module RustLib

using Libdl
import ..LIB_RUST

const LIB_PTR = Ref{Ptr{Nothing}}(C_NULL) # Ref{Ptr{Cvoid}}(C_NULL)
const FUNC_PROCESS = Ref{Ptr{Nothing}}(C_NULL)
const FUNC_FREE = Ref{Ptr{Nothing}}(C_NULL)

function init()

    if LIB_PTR[] == C_NULL
        LIB_PTR[] = Libdl.dlopen(LIB_RUST)
        FUNC_PROCESS[] = Libdl.dlsym(LIB_PTR[], :process_string)
        FUNC_FREE[] = Libdl.dlsym(LIB_PTR[], :free_string)
    end

end

function process_text(input::String)
    # Safety check
    init()

    # Call Rust: returns a pointer to a C-style string
    # process_string(input: *const c_char) -> *mut c_char
    ptr = @ccall $(FUNC_PROCESS[])(input::Cstring)::Ptr{Cchar}

    if ptr == C_NULL
        return "Error: null pointer from Rust"
    end

    # Copy data from the pointer into a Julia-managed String
    result = unsafe_string(ptr)

    # Free the memory it allocated
    # free_string(ptr: *mut c_char)
    @ccall $(FUNC_FREE[])(ptr::Ptr{Cchar})::Cvoid

    return result
end

end # RustLib


function main()

    println("Checking library at: $LIB_RUST")
    if !isfile(LIB_RUST)
        error("Library not found! Did you run 'cargo build --release'?")
    end

    test_cases = ["Julia", "Safety first with Rust", "λ - Unicode Test"]

    for text in test_cases
        response = RustLib.process_text(text)
        println("Julia: $text")
        println("Rust: $response")
        println("-"^30)
    end

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
