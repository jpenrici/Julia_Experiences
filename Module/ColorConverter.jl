# ColorConverter.jl

module ColorConverter

    import Base: show

    using Printf

    export RGBA, to_hex, to_str

    struct RGBA
        r::Int
        g::Int
        b::Int
        a::Int

        # Constructor
        function RGBA(r, g, b, a)
            if all(0 .<= [r,  g, b, a] .<= 255)
                return new(r, g, b, a)
            else
                error("Color values must be between 0 and 255")
            end
        end
    end # RGBA

    function to_hex(c::RGBA)
        return @sprintf("#%02X%02X%02X%02X", c.r, c.g, c.b, c.a)
    end

    function to_str(c::RGBA)
        return "RGBA: ($(c.r), $(c.g), $(c.b), $(c.a))"
    end

    # Overloading the base show function
    function show(io::IO, c::RGBA)
        print(io, "$(c.r), $(c.g), $(c.b), $(c.a)")
    end

end # module
