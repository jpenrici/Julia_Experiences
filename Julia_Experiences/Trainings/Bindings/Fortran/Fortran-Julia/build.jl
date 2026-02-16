# build.jl

using Libdl

function build_project()
    project_root = @__DIR__
    build_dir = joinpath(project_root, "build")
    lib_dir = joinpath(project_root, "lib")

    @info "Starting the build process..."

    if !ispath(build_dir)
        mkpath(build_dir)
    end

    cd(build_dir) do
        @info "Setting up CMake..."
        run(`cmake .. -DCMAKE_BUILD_TYPE=Release`)

        @info "Compiling the library..."
        run(`cmake --build . --config Release`)
    end

    lib_name = Sys.iswindows() ? "calc.dll" : (Sys.isapple() ? "libcalc.dylib" : "libcalc.so")
    expected_lib = joinpath(lib_dir, lib_name)

    if isfile(expected_lib)
        @info "SUCCESS: Library found in $expected_lib"
    else
        @warn "WARNING: Library not found on the expected path: $expected_lib"
        @info "Checking build directory..."

        for (root, dirs, files) in walkdir(build_dir)
            if lib_name in files
                @info "Library found in the build: $(joinpath(root, lib_name))"
                return
            end
        end
        error("Failure in the build: Binary file not generated.")
    end

end # build_project


if abspath(PROGRAM_FILE) == @__FILE__
    build_project()
end
