using CSV
using DataFrames
using Serialization
using PrettyTables
using Turing

include(joinpath(pwd(), "src", "models.jl"))

function make_df(x::Matrix; type, dependent=false)
    df = reduce(vcat, DataFrame(x[:, i]) for i in 1:size(x, 2))
    if !dependent
        select!(df, Not(:dependent))
    end
    if type == "full"
        df = select(
            transform(df, :β_control => AsTable),
            Not(:β_control),
            [:x1, :x2, :x3] .=> ["β_control[1]", "β_control[2]", "β_control[3]"],
        )
        df = select(
            transform(df, :α_med_j => AsTable),
            Not(:α_med_j),
            [:x1, :x2, :x3] .=> ["α_med_j[1]", "α_med_j[2]", "α_med_j[3]"],
        )
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
        select!(df, Not([:x1, :x2, :x3]))
    end
    summ = describe(
        df,
        :mean,
        :std,
        :median,
        (x -> quantile(x, 0.05)) => :q05,
        (x -> quantile(x, 0.95)) => :q95,
    )
    return summ
end

function make_summary(x::AbstractMatrix, title::AbstractString; type, dependent=false)
    summ = make_df(x; type, dependent)
    return pretty_table(
        summ;
        nosubheader=true,
        alignment=:l,
        formatters=ft_round(3),
        linebreaks=true,
        title=title,
    )
end

# Loading chains
date = "2021-10-15"
chn_mediation = deserialize(joinpath(pwd(), "chains", "mediation_$date.jls"))
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))

# generating table
gen_mediation = generated_quantities(
    mediation, MCMCChains.get_sections(chn_mediation, :parameters)
)
gen_full = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
make_summary(gen_mediation, "Mediation $date"; type="mediation")
make_summary(gen_full, "Model $date"; type="full")

# saving table
make_df(gen_mediation; type="mediation") |>
    CSV.write(joinpath(pwd(), "tables", "mediation_summary_$date.csv"))
make_df(gen_full; type="full") |>
    CSV.write(joinpath(pwd(), "tables", "full_summary_$date.csv"))
