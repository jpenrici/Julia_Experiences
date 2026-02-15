# svgProcessor.jl

module SVGProcessor

import DataFrames as DF
import EzXML

using EzXML: readxml, eachelement, eachattribute

export FilePath, Element, parse_svg_file, parse_svg_dataframe

struct Element
    tag_name::String
    attributes::Dict{String,String}
    content::String
end

struct FilePath
    path::String

    function FilePath(path::String)
        if !isfile(path)
            @error("File not found: $path")
        else
            return new(path)
        end
    end
end

"""
parse_svg_file(file_path::FilePath)
Returns a Vector of Element structs.
"""
function parse_svg_file(file_obj::FilePath)::Vector{Element}

    path = file_obj.path
    if !isfile(path)
        error("File not found: $path")
    end

    doc = readxml(path)
    root = EzXML.root(doc)

    elements = Element[]

    for node in eachelement(root)
        attrs = Dict(attr.name => attr.content for attr in eachattribute(node))
        push!(elements, Element(node.name, attrs, node.content))
    end

    return elements
end

"""
parse_svg_dataframe(file_path::FilePath)
Converts SVG elements into a DataFrame for tabular analysis.
Dispatch for FilePath object.
"""
function parse_svg_dataframe(file_obj::FilePath)::DF.DataFrame
    return parse_svg_dataframe(parse_svg_file(file_obj))
end

"""
parse_svg_dataframe(elements::Vector{Element})
Converts SVG elements into a DataFrame for tabular analysis.
Dispatch for the actual Vector of structs.
"""
function parse_svg_dataframe(elements::Vector{Element})::DF.DataFrame
    if isempty(elements)
        @warn "Data is empty!"
        return DF.DataFrame()
    end
    rows = []
    for elem in elements
        attr_str = join(["$(k):$(v)" for (k, v) in elem.attributes], ", ")
        row = (tag = elem.tag_name, attributes = attr_str, content = strip(elem.content))
        push!(rows, row)
    end
    return DF.DataFrame(rows)
end

end # SVGProcessor
