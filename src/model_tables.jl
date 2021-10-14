using CSV
using DataFrames
using Serialization
using PrettyTables
using Turing

include(joinpath(pwd(), "src", "models.jl"))

function make_df(x::Matrix; dependent=false)
    df = reduce(vcat, DataFrame(x[:, i]) for i ∈ 1:size(x, 2))
    if !dependent
        select!(df, Not(:dependent))
    end
    df = select(transform(df, :β_control => AsTable),
                Not(:β_control),
                [:x1, :x2, :x3] .=> ["β_control[1]", "β_control[2]", "β_control[3]"])
    df = select(transform(df, :α_med_j => AsTable),
                Not(:α_med_j),
                [:x1, :x2, :x3] .=> ["α_med_j[1]", "α_med_j[2]", "α_med_j[3]"])
    df = select(transform(df, :α_dep_j => AsTable),
                Not(:α_dep_j),
                [:x1, :x2, :x3] .=> ["α_dep_j[1]", "α_dep_j[2]", "α_dep_j[3]"])
    select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
    select!(df, Not([:x1, :x2, :x3]))
    summ = describe(df, :mean, :std, :median,
                        (x -> quantile(x, 0.05)) => :q05,
                        (x -> quantile(x, 0.95)) => :q95)
    return summ
end

function make_summary(x::AbstractMatrix, title::AbstractString;
                      dependent=false)
    summ = make_df(x; dependent)
    return pretty_table(summ;
                        nosubheader=true, alignment=:l,
                        formatters=ft_round(3), linebreaks=true,
                        title=title)
end

# Loading chains
date = "2021-10-14"
chn_full = deserialize(joinpath(pwd(), "chains", "model_$date.jls"))

# generating table
gen = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
make_summary(gen, "Model $date")

# saving table
make_df(gen) |> CSV.write(joinpath(pwd(), "tables", "model_summary_$date.csv"))
