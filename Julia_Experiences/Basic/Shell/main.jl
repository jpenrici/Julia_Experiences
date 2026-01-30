# main.jl

# Function to scan the shell script for function definitions
function discover_functions(filepath::String)
    functions = Symbol[]
    # Regex pattern: word characters followed by parentheses and optional space/brace
    # Example match: my_func() {
    pattern = r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)\s*\{"

    open(filepath, "r") do file
        for line in eachline(file)
            m = match(pattern, strip(line))
            if m !== nothing
                push!(functions, Symbol(m.captures[1]))
                end
            end
        end
    return functions
end

# Advanced Macro to bridge Julia and Shell Functions
macro wrap_sh_functions(file_path)

    path_val = Core.eval(__module__, file_path)
    abs_path = abspath(path_val)

    # Automatically find functions in the file
    func_names = discover_functions(abs_path)

    expr_block = quote end

    for func_sym in func_names
        func_str = string(func_sym)
        julia_func_name = Symbol("sh_", func_str)

        push!(expr_block.args, quote
              function $julia_func_name(args::String...)
                  # Combine source and function call for bash
                  full_command = "source " * $abs_path * "; " * $func_str * " " * join(args, " ")
                  @info "Calling Shell Function: $($(func_str))"
                  run(`bash -c $full_command`)
              end
              export $julia_func_name
        end)
    end

    return esc(expr_block)
end

# Execution Logic - Test
const SCRIPT_PATH = "functions.sh"

if abspath(PROGRAM_FILE) == @__FILE__

    if !isfile(SCRIPT_PATH)
        error("Error: $SCRIPT_PATH not found!")
    end

    @wrap_sh_functions SCRIPT_PATH

    # Test the discovered functions
    try
        sh_hello_user("User")
        sh_check_space("~")
    catch e
        @warn "Some functions might not have been generated: $e"
    end
end
