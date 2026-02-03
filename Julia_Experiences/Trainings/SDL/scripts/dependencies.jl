# dependencies.jl

using Pkg


function install_missing_packages()
    try
        required = ["SimpleDirectMediaLayer", "ColorTypes"]
        project_deps = Pkg.project().dependencies

        println("--- Checking Dependencies ---")
        for pkg in required
            if haskey(project_deps, pkg)
                @info "$pkg is already installed."
            else
                @info "Installing $pkg..."
                Pkg.add(pkg)
            end
        end

        println("--- Precompiling ---")
        Pkg.precompile()

        return true
    catch e
        @error "Failed to setup dependencies" exception=e
        return false
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    Pkg.activate("..")
    status = install_missing_packages()
    if status
        exit(0)
    else
        exit(1)
    end
end
