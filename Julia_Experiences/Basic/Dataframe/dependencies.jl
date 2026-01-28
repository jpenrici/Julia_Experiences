# dependencies.jl

using Pkg


function install_missing_packages()
    # List of required packages
    required = ["DataFrames", "XLSX", "Dates", "Random"]

    # Get a list of currently installed packages in the active environment
    installed_packages = keys(Pkg.project().dependencies)

    println("--- Checking Dependencies ---")

    for pkg in required
        if pkg in installed_packages
            println("[SKIP] $pkg is already installed.")
        else
            println("[INST] Installing $pkg...")
            Pkg.add(pkg)
        end
    end

    println("--- All dependencies are ready! ---")
end


if abspath(PROGRAM_FILE) == @__FILE__
    Pkg.activate(".")
    install_missing_packages()
    Pkg.precompile()
end
