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
date = "2021-09-22"
mediation_chn_all = deserialize(joinpath(pwd(), "chains", "mediation_all_$date.jls"))
mediation_chn_tv = deserialize(joinpath(pwd(), "chains", "mediation_tv_$date.jls"))
mediation_chn_np = deserialize(joinpath(pwd(), "chains", "mediation_np_$date.jls"))
mediation_chn_sm = deserialize(joinpath(pwd(), "chains", "mediation_sm_$date.jls"))


# generating indirect vs direct effects
gen_all = generated_quantities(mediation_all, MCMCChains.get_sections(mediation_chn_all, :parameters))
gen_tv = generated_quantities(mediation_tv, MCMCChains.get_sections(mediation_chn_tv, :parameters))
gen_np = generated_quantities(mediation_np, MCMCChains.get_sections(mediation_chn_np, :parameters))
gen_sm = generated_quantities(mediation_sm, MCMCChains.get_sections(mediation_chn_sm, :parameters))

make_summary(gen_all, "All Media Combined")
make_summary(gen_tv, "Only TV")
make_summary(gen_np, "Only Newspaper")
make_summary(gen_sm, "Only Social Media")
