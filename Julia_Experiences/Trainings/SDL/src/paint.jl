# paint.jl
# References:
#   https://wiki.libsdl.org/SDL2/FrontPage
#   https://github.com/JuliaMultimedia/SimpleDirectMediaLayer.jl

module JuliaPaint

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using ColorTypes

include("engine.jl")

export run_app, PaintState

end # JuliaPaint
