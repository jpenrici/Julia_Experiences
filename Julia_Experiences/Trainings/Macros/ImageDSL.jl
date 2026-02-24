# ImageDSL.jl
# DSL module for image transformation pipelines
# Skeleton — all signatures declared, no implementation yet

module ImageDSL

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


# ─────────────────────────────────────────────
# TYPED IMAGE STRUCTS — used by @generated dispatch
# ─────────────────────────────────────────────

struct RGBImage
    path::String
    # data::Array{RGB, 2}   # uncomment when Images.jl is integrated
end

struct GrayImage
    path::String
    # data::Array{Gray, 2}  # uncomment when Images.jl is integrated
end

# Union for dispatch
const AnyImage = Union{RGBImage,GrayImage}


# ─────────────────────────────────────────────
# MACRO @apply
# Validates a single operation at parse time
# Usage: @apply blur("input/foto.png", radius=3, output="output/blur.png")
# ─────────────────────────────────────────────

macro apply(expr)
    # expr arrives as an AST node — inspect before generating code
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
Used to drive @generated dispatch downstream.
"""
function load_typed(path::String)::AnyImage
    error("not implemented: load_typed")
end

"""
apply_contrast(img, factor) -> AnyImage

@generated function — specializes at compile time per image type.
No runtime branching between RGB and Gray paths.
"""
@generated function apply_contrast(img::T, ; factor::Float64 = 1.0) where {T<:AnyImage}
    error("not implemented: apply_contrast for $T")
end

"""
describe(img) -> Nothing

Prints which type specialization is active for this image.
"""
function describe(img::AnyImage)
    error("not implemented: describe")
end

"""
validate(op, kwargs...) -> Symbol

Validates an operation and its params independently of macros.
Returns :ok or throws a DSLError.
Useful for unit testing validation logic in isolation.
"""
function validate(op::Symbol; kwargs...)
    error("not implemented: validate")
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

# Parses a macro call expression into (operation, args, kwargs)
#
# Expects an Expr with this AST shape:
#   Expr(:call, :op_name, arg1, Expr(:kw, :key, value), ...)
#
# Returns:
#   op     :: Symbol          — operation name, e.g. :blur
#   args   :: Vector{Any}     — positional arguments, e.g. ["input/foto.png"]
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
            key = node.args[1]  # Symbol
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
    if op ∉ VALID_OPERATIONS
        valid_list = join(VALID_OPERATIONS, ", ")
        error("DSL error: unknown operation ':$op'. Valid operations: $valid_list")
    end

    # -- Layer 2: all required params must be present -------------------------
    required = REQUIRED_PARAMS[op]
    missing_params = filter(p -> p ∉ keys(kwargs), required)

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
function _generate_apply(op::Symbol, args, kwargs)
    error("not implemented: _generate_apply")
end

# Extracts ordered list of steps from a begin...end block
function _parse_pipeline_block(block::Expr)
    error("not implemented: _parse_pipeline_block")
end

# Throws at parse time if load/save ordering rules are violated
function _validate_pipeline_order!(steps)
    error("not implemented: _validate_pipeline_order!")
end

# Returns the Expr that @pipeline will expand into
function _generate_pipeline(name::QuoteNode, steps)
    error("not implemented: _generate_pipeline")
end

end # module ImageDSL
