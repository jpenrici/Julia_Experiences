# ImageDSL.jl
# DSL (Domain Specific Language) module for image transformation pipelines

module ImageDSL

using Images
using ImageFiltering
using ImageTransformations
using FileIO
using ColorTypes

export @apply, @pipeline


# ─────────────────────────────────────────────
# SUPPORTED OPERATIONS — used for parse-time validation
# ─────────────────────────────────────────────

const VALID_OPERATIONS = [:blur, :grayscale, :resize, :save, :load]

const REQUIRED_PARAMS = Dict(
    :blur => [:radius],
    :resize => [:width, :height],
    :grayscale => [],
    :load => [],
    :save => [],
)

# Pipeline ordering rules
const PIPELINE_FIRST_OP = :load
const PIPELINE_LAST_OP = :save


# ─────────────────────────────────────────────
# TYPED IMAGE STRUCTS — used by @generated dispatch
# ─────────────────────────────────────────────

struct RGBImage
    path::String
    data::Matrix{RGB{Float32}}
end

struct GrayImage
    path::String
    data::Matrix{Gray{Float32}}
end

# Union for dispatch
const AnyImage = Union{RGBImage,GrayImage}


# ─────────────────────────────────────────────
# MACRO @apply
# Validates a single operation at parse time
# Usage: @apply blur("input/foto.png", radius=3, output="output/blur.png")
# ─────────────────────────────────────────────

macro apply(expr)
    # expr arrives as an AST (Abstract Syntax Tree) node — inspect before generating code
    op, args, kwargs = _parse_operation(expr)

    # parse-time validation — runs before any code executes
    _validate_operation!(op, kwargs)

    # code generation — returns the expression that will actually run
    return _generate_apply(op, args, kwargs)
end


# ─────────────────────────────────────────────
# MACRO @pipeline
# Validates step ordering and params at parse time
# Usage:
#   @pipeline :name begin
#       load("input/foto.png")
#       grayscale()
#       save("output/result.png")
#   end
# ─────────────────────────────────────────────

macro pipeline(name, block)
    steps = _parse_pipeline_block(block)

    # parse-time ordering rules
    _validate_pipeline_order!(steps)

    # generate chained calls
    return _generate_pipeline(name, steps)
end


# ─────────────────────────────────────────────
# PUBLIC API — callable without macros
# ─────────────────────────────────────────────

"""
load_typed(path) -> RGBImage | GrayImage

Loads an image and returns a typed struct based on its color space.
Drives @generated dispatch downstream — no runtime branching needed.
"""
function load_typed(path::String)::AnyImage
    raw = FileIO.load(path)

    if eltype(raw) <: AbstractRGB
        return RGBImage(path, convert(Matrix{RGB{Float32}}, raw))
    else
        return GrayImage(path, convert(Matrix{Gray{Float32}}, raw))
    end
end

"""
apply_contrast(img; factor) -> AnyImage

@generated function — specializes at compile time per image type.
RGB path clamps each channel independently.
Gray path clamps the single luminance channel.
No runtime if/else — the branch is resolved during compilation.
"""
@generated function apply_contrast(img::T; factor::Float64 = 1.0) where {T<:AnyImage}
    if T === RGBImage
        return quote
            adjusted = clamp01.(img.data .* factor)
            RGBImage(img.path, adjusted)
        end
    elseif T === GrayImage
        return quote
            adjusted = clamp01.(img.data .* factor)
            GrayImage(img.path, adjusted)
        end
    end
end

"""
describe(img) -> Nothing

Prints the active type specialization and basic image metadata.
Useful for verifying @generated dispatch during learning.
"""
function describe(img::RGBImage)
    h, w = size(img.data)
    println("Type  : RGBImage  (specialization: RGB path)")
    println("Path  : $(img.path)")
    println("Size  : $(w)x$(h) pixels")
    println("Eltype: $(eltype(img.data))")
end

function describe(img::GrayImage)
    h, w = size(img.data)
    println("Type  : GrayImage  (specialization: Gray path)")
    println("Path  : $(img.path)")
    println("Size  : $(w)x$(h) pixels")
    println("Eltype: $(eltype(img.data))")
end

"""
validate(op; kwargs...) -> Symbol

Validates an operation and params independently of macros.
Returns :ok or throws a descriptive DSL error.
Useful for unit testing validation logic in isolation.
"""
function validate(op::Symbol; kwargs...)
    kw_dict = Dict{Symbol,Any}(kwargs)
    _validate_operation!(op, kw_dict)
    return :ok
end


# ─────────────────────────────────────────────
# INTERNAL HELPERS — not exported
# ─────────────────────────────────────────────


"""
inspect_ast(expr) -> Nothing

Learning helper — prints the raw AST structure of any expression.
Use this to understand what arrives inside a macro before parsing.

Example:
inspect_ast(:( blur("input/foto.png", radius=3) ))
"""
function inspect_ast(expr)
    println("=== AST dump ===")
    dump(expr)
    println("=== AST string ===")
    println(repr(expr))
end


# ─────────────────────────────────────────────
# INTERNAL — PARSE
# ─────────────────────────────────────────────


# Parses a macro call expression into (operation, args, kwargs)
#
# Expects an Expr with this AST shape:
#   Expr(:call, :op_name, arg1, Expr(:kw, :key, value), ...)
#
# Returns:
#   op     :: Symbol           — operation name, e.g. :blur
#   args   :: Vector{Any}      — positional arguments, e.g. ["input/foto.png"]
#   kwargs :: Dict{Symbol,Any} — keyword arguments, e.g. Dict(:radius => 3)
#
function _parse_operation(expr::Expr)

    # Guard: must be a function-call expression
    if expr.head != :call
        error("DSL error: expected a function call, got: $(expr.head)")
    end

    # First element of args is always the operation name
    op = expr.args[1]

    if !isa(op, Symbol)
        error("DSL error: operation name must be a Symbol, got: $(typeof(op))")
    end

    # Separate positional args from keyword args
    # Keyword args arrive as Expr(:kw, :name, value) nodes
    args = Any[]
    kwargs = Dict{Symbol,Any}()

    for node in expr.args[2:end]
        if isa(node, Expr) && node.head == :kw
            # Keyword argument — extract name and value from the :kw node
            key = node.args[1]    # Symbol
            value = node.args[2]  # literal value or nested Expr
            kwargs[key] = value

        elseif isa(node, Expr) && node.head == :parameters
            # Julia sometimes groups trailing kwargs under a :parameters node
            # e.g. @apply blur("file.png"; radius=3)  ← semicolon syntax
            for kw in node.args
                if isa(kw, Expr) && kw.head == :kw
                    kwargs[kw.args[1]] = kw.args[2]
                end
            end

        else
            # Positional argument — string path, number, symbol, etc.
            push!(args, node)
        end
    end

    return op, args, kwargs
end

# Throws at parse time if operation or params are invalid
#
# Validation runs in three cascading layers:
#   1. Is the operation known?
#   2. Are all required params present?
#   3. Are the param values semantically valid?
#
# All errors thrown here surface as compile-time errors to the macro caller.
#
function _validate_operation!(op::Symbol, kwargs::Dict{Symbol,Any})

    # -- Layer 1: operation must exist in the DSL vocabulary ------------------
    # if op ∉ VALID_OPERATIONS
    if !in(op, VALID_OPERATIONS)
        valid_list = join(VALID_OPERATIONS, ", ")
        error("DSL error: unknown operation ':$op'. Valid operations: $valid_list")
    end

    # -- Layer 2: all required params must be present -------------------------
    required = REQUIRED_PARAMS[op]
    missing_params = [p for p in REQUIRED_PARAMS[op] if !in(p, keys(kwargs))]

    if !isempty(missing_params)
        missing_list = join(missing_params, ", ")
        error("DSL error: operation ':$op' missing required params: $missing_list")
    end

    # -- Layer 3: semantic rules per operation --------------------------------
    _validate_semantics!(op, kwargs)

end

# Semantic rules isolated per operation — easy to extend
# Each clause is a contract: "what makes this operation valid?"
function _validate_semantics!(op::Symbol, kwargs::Dict{Symbol,Any})

    if op == :blur
        radius = get(kwargs, :radius, nothing)

        # radius must be a positive integer
        if !isa(radius, Integer)
            error("DSL error: blur 'radius' must be an Integer, got: $(typeof(radius))")
        end
        if radius <= 0
            error("DSL error: blur 'radius' must be positive, got: $radius")
        end
        # radius should be odd for symmetric kernels — warn but dont block
        if iseven(radius)
            @warn "DSL warning: blur 'radius=$radius' is even. Odd values produce symmetric kernels."
        end

    elseif op == :resize
        width = get(kwargs, :width, nothing)
        height = get(kwargs, :height, nothing)

        if !isa(width, Integer) || width <= 0
            error("DSL error: resize 'width' must be a positive Integer, got: $width")
        end
        if !isa(height, Integer) || height <= 0
            error("DSL error: resize 'height' must be a positive Integer, got: $height")
        end

    elseif op == :load
        # no extra semantic rules beyond positional arg (path) — validated elsewhere

    elseif op == :save
        # no extra semantic rules beyond positional arg (path) — validated elsewhere

    elseif op == :grayscale
        # no params — nothing to validate semantically

    end
    # New operations: add elseif clauses here.
    # If an operation has no semantic rules, it passes silently.

end

# Returns the Expr that @apply will expand into
#
# This function does NOT execute the operation.
# It BUILDS the code that will execute when the macro expansion runs.
#
# Key concepts:
#   quote ... end    writes destination code naturally; Julia builds the AST
#   $(value)         interpolates a compile-time value into the generated code
#
# Example output for @apply blur("input/foto.png", radius=3, output="output/blur.png"):
#   ImageDSL._rt_blur("input/foto.png", radius=3, output="output/blur.png")
#
function _generate_apply(op::Symbol, args::Vector{Any}, kwargs::Dict{Symbol,Any})

    # Build keyword argument nodes for the generated call
    # Each kwargs entry becomes Expr(:kw, :name, value) in the output AST
    kwarg_exprs = [Expr(:kw, k, v) for (k, v) in kwargs]

    # Resolve which internal runtime function handles this operation
    # Indirection keeps DSL names decoupled from implementation names
    runtime_fn = _resolve_runtime_fn(op)

    # quote builds the output Expr naturally
    # $(runtime_fn)      interpolates the target function Symbol
    # $(args...)         splats positional arguments into the generated call
    # $(kwarg_exprs...)  splats keyword argument nodes into the generated call
    return quote
        $runtime_fn($(args...), $(kwarg_exprs...))
    end

end

# Maps DSL operation symbols to their internal runtime function symbols
# Allows runtime functions to evolve independently of DSL-facing names
function _resolve_runtime_fn(op::Symbol)::Symbol
    dispatch = Dict(
        :blur => :_rt_blur,
        :grayscale => :_rt_grayscale,
        :resize => :_rt_resize,
        :load => :_rt_load,
        :save => :_rt_save,
    )
    return dispatch[op]
end


# ─────────────────────────────────────────────
# RUNTIME FUNCTIONS — Images.jl integration
# Prefixed _rt_ to distinguish from DSL-level names
# All intermediate steps receive and return AnyImage
# ─────────────────────────────────────────────

# Loads from disk — entry point of every pipeline
function _rt_load(path::String)::AnyImage
    return load_typed(path)
end

# Saves to disk — exit point of every pipeline
function _rt_save(img::AnyImage, path::String = "")
    out = isempty(path) ? img.path : path
    FileIO.save(out, img.data)
    @info "Saved: $out"
end

# Also accepts a path directly for @apply usage
function _rt_save(path::String; output::String = "")
    out = isempty(output) ? path : output
    @warn "_rt_save called without image data — nothing to save to $out"
end

# Applies Gaussian blur via ImageFiltering
function _rt_blur(img::AnyImage; radius::Int = 1, output::String = "")::AnyImage
    kernel = ImageFiltering.Kernel.gaussian(radius)
    blurred = imfilter(img.data, kernel)

    result = img isa RGBImage ? RGBImage(img.path, blurred) : GrayImage(img.path, blurred)
    isempty(output) || FileIO.save(output, result.data)
    return result
end

# @apply entry — loads from path, blurs, saves
function _rt_blur(path::String; radius::Int = 1, output::String = "")
    img = load_typed(path)
    result = _rt_blur(img; radius = radius)
    out = isempty(output) ? path : output
    FileIO.save(out, result.data)
    @info "blur applied — saved to $out"
end

# Converts to grayscale — if already Gray, passes through
function _rt_grayscale(img::RGBImage; output::String = "")::GrayImage
    gray_data = convert(Matrix{Gray{Float32}}, Gray.(img.data))
    result = GrayImage(img.path, gray_data)
    isempty(output) || FileIO.save(output, result.data)
    return result
end

function _rt_grayscale(img::GrayImage; output::String = "")::GrayImage
    return img  # already grayscale — no-op
end

# @apply entry
function _rt_grayscale(path::String; output::String = "")
    img = load_typed(path)
    result = _rt_grayscale(img)
    out = isempty(output) ? path : output
    FileIO.save(out, result.data)
    @info "grayscale applied — saved to $out"
end

# Resizes using ImageTransformations
function _rt_resize(
    img::AnyImage;
    width::Int = 0,
    height::Int = 0,
    output::String = "",
)::AnyImage
    resized = ImageTransformations.imresize(img.data, (height, width))

    result = img isa RGBImage ? RGBImage(img.path, resized) : GrayImage(img.path, resized)
    isempty(output) || FileIO.save(output, result.data)
    return result
end

# @apply entry
function _rt_resize(path::String; width::Int = 0, height::Int = 0, output::String = "")
    img = load_typed(path)
    result = _rt_resize(img; width = width, height = height)
    out = isempty(output) ? path : output
    FileIO.save(out, result.data)
    @info "resize applied ($(width)x$(height)) — saved to $out"
end

# Extracts an ordered list of (op, args, kwargs) tuples from a begin...end block
#
# Input AST shape:
#   Expr(:block,
#     Expr(:call, :load, "input/foto.png"),
#     Expr(:call, :grayscale),
#     Expr(:call, :save, "output/result.png")
#   )
#
function _parse_pipeline_block(block::Expr)
    if block.head != :block
        error("DSL error: @pipeline expects a begin...end block, got: $(block.head)")
    end

    steps = Tuple{Symbol,Vector{Any},Dict{Symbol,Any}}[]

    for node in block.args
        # skip line number nodes — Julia injects these automatically into blocks
        isa(node, LineNumberNode) && continue

        if !isa(node, Expr) || node.head != :call
            error(
                "DSL error: each pipeline step must be a function call, got: $(repr(node))",
            )
        end

        op, args, kwargs = _parse_operation(node)
        push!(steps, (op, args, kwargs))
    end

    return steps
end

# Validates pipeline step ordering rules:
#   - first step must be load()
#   - last step must be save()
#   - no load() or save() in the middle
#
function _validate_pipeline_order!(steps)
    if isempty(steps)
        error("DSL error: @pipeline block is empty")
    end

    first_op = steps[1][1]
    last_op = steps[end][1]

    first_op != PIPELINE_FIRST_OP &&
        error("DSL error: pipeline must start with load(), got: :$first_op")

    last_op != PIPELINE_LAST_OP &&
        error("DSL error: pipeline must end with save(), got: :$last_op")

    # Middle steps must not contain load() or save()
    for (op, _, _) in steps[2:(end-1)]
        op == :load && error("DSL error: load() can only appear as the first step")
        op == :save && error("DSL error: save() can only appear as the last step")
    end
end

# Generates a pipeline as a sequential let block
# Each step receives the output of the previous one via the `_img` binding
#
# Generated shape for @pipeline :name begin load / op / save end:
#
#   let _pipeline_name = :name
#       _img = _rt_load("input/foto.png")
#       _img = _rt_grayscale(_img)
#       _img = _rt_save(_img, output="output/result.png")
#   end
#
function _generate_pipeline(name::QuoteNode, steps)
    exprs = Expr[]

    # First step is always load — returns the initial image
    load_op, load_args, load_kwargs = steps[1]
    load_kwarg_exprs = [Expr(:kw, k, v) for (k, v) in load_kwargs]
    load_fn = _resolve_runtime_fn(load_op)
    push!(exprs, :(local _img = $load_fn($(load_args...), $(load_kwarg_exprs...))))

    # Middle steps — each takes _img and returns a new _img
    for (op, args, kwargs) in steps[2:(end-1)]
        kwarg_exprs = [Expr(:kw, k, v) for (k, v) in kwargs]
        fn = _resolve_runtime_fn(op)
        push!(exprs, :(_img = $fn(_img, $(args...), $(kwarg_exprs...))))
    end

    # Last step is always save — writes _img to disk
    save_op, save_args, save_kwargs = steps[end]
    save_kwarg_exprs = [Expr(:kw, k, v) for (k, v) in save_kwargs]
    save_fn = _resolve_runtime_fn(save_op)
    push!(exprs, :($save_fn(_img, $(save_args...), $(save_kwarg_exprs...))))

    return quote
        let _pipeline_name = $name
            @info "Running pipeline: $_pipeline_name"
            $(exprs...)
        end
    end
end

end # module ImageDSL
