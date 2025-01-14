module AttrGroups

using JSON
using DelimitedFiles
using Pkg.Artifacts

_symbol_dict(x) = x
_symbol_dict(d::AbstractDict) =
    Dict{Symbol,Any}([(Symbol(k), _symbol_dict(v)) for (k, v) in d])

function main()

    data = _symbol_dict(JSON.parsefile(joinpath(artifact"plotly-artifacts", "plot-schema.json")))[:schema]

    nms = Set{Symbol}()
    function add_to_names!(d::AbstractDict)
        foreach(add_to_names!, keys(d))
        foreach(add_to_names!, values(d))
        nothing
    end
    add_to_names!(s::Symbol) = push!(nms, s)
    add_to_names!(x) = nothing

    add_to_names!(data[:layout][:layoutAttributes])
    for (_, v) in data[:traces]
        add_to_names!(v)
    end

    _UNDERSCORE_ATTRS = collect(
        filter(
            x-> occursin(string(x), "_") && !startswith(string(x), "_"),
            nms
        )
    )

    _SRC_ATTRS = collect(filter(x -> endswith(string(x), "src"), nms))

    open(joinpath(@__DIR__, "src_attrs.csv"), "w") do f
        writedlm(f, map(string, _SRC_ATTRS))
    end

    open(joinpath(@__DIR__, "underscore_attrs.csv"), "w") do f
        writedlm(f, map(string, _UNDERSCORE_ATTRS))
    end

    _UNDERSCORE_ATTRS, _SRC_ATTRS
end



end  # module
