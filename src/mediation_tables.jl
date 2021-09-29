using Serialization
using PrettyTables

include(joinpath(pwd(), "src", "models.jl"))

function make_df(x::Matrix)
    df = reduce(vcat, DataFrame(x[:, i]) for i ∈ 1:size(x, 2))
    summ = describe(df, :mean, :std, :median,
                        (x -> quantile(x, 0.05)) => :q05,
                        (x -> quantile(x, 0.95)) => :q95)
    return summ
end

function make_summary(x::AbstractMatrix, title::AbstractString)
    summ = make_df(x)
    return pretty_table(summ; nosubheader=true, formatters=ft_round(3), title=title)
end

# Loading chains
date = "2021-09-29"
mediation_chn = deserialize(joinpath(pwd(), "chains", "mediation_$date.jls"))


# generating indirect vs direct effects
gen = generated_quantities(mediation, MCMCChains.get_sections(mediation_chn, :parameters))

make_summary(gen, "Mediation Test")
