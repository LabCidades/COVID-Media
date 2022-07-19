using DataFrames
using DataFramesMeta
using MCMCChains
using Turing
using Serialization
using Statistics

include(joinpath(pwd(), "src", "models.jl"))

# Calculating R2 according to DOI 10.1080/00031305.2018.1549100

# getting real y (standardized)
y = df[:, :be_mean_std]
mean_y = mean(y)
std_y = std(y)
var_y = var(y)

function make_df(x::Matrix; type, dependent=false)
    df = reduce(vcat, DataFrame(x[:, i]) for i in 1:size(x, 2))
    if !dependent
        select!(df, Not(:dependent))
    end
    if type == "full_media_type"
        df = select(
            transform(df, :β_control_med => AsTable),
            Not(:β_control_med),
            [:x1, :x2, :x3] .=>
                ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_control_dep => AsTable),
            Not(:β_control_dep),
            [:x1, :x2, :x3] .=>
                ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_media_type_med => AsTable),
            Not(:β_media_type_med),
            [:x1, :x2, :x3, :x4] .=> [
                "β_media_type_med[1]",
                "β_media_type_med[2]",
                "β_media_type_med[3]",
                "β_media_type_med[4]",
            ],
        )
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^β_media_type_med"), :)
        select!(df, Not([:x1, :x2, :x3, :x4]))
    elseif type == "full"
        df = select(
            transform(df, :β_control_med => AsTable),
            Not(:β_control_med),
            [:x1, :x2, :x3] .=>
                ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_control_dep => AsTable),
            Not(:β_control_dep),
            [:x1, :x2, :x3] .=>
                ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
        )
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
        select!(df, Not([:x1, :x2, :x3]))
    elseif type == "interaction"
        df = select(
            transform(df, :β_control => AsTable),
            Not(:β_control),
            [:x1, :x2] .=> ["β_control[1]", "β_control[2]"],
        )
        select!(df, Not([:x1, :x2]))
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
    end
    summ = describe(
        df,
        :mean,
        :std,
        :median,
        (x -> quantile(x, 0.025)) => :q025,
        (x -> quantile(x, 0.975)) => :q975,
    )
    return summ
end

# Loading chains
date = "2022-06-07"
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))
chn_full_media_type = deserialize(joinpath(pwd(), "chains", "full_media_type_$date.jls"))

# getting generated generated
gen_full = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
gen_full_media_type = generated_quantities(
    full_media_type, MCMCChains.get_sections(chn_full_media_type, :parameters)
)

# getting the summary stats for parameters
df_full = make_df(gen_full; type="full")
df_full_media_type = make_df(gen_full_media_type; type="full_media_type")

# Calculating the ŷ
α_med_full = df_full[3, :mean]
β_indep_med_full = df_full[1, :mean]
β_control_med_full = df_full[4:6, :mean]
α_dep_full = df_full[10, :mean]
β_med_dep_full = df_full[2, :mean]
β_control_dep_full = df_full[7:9, :mean]

full_pred = @select df @astable begin
    :mediator = α_med_full .+ :hmtime_std .* β_indep_med_full .+ :age_std .* β_control_med_full[1] .+ :sex_male_std .* β_control_med_full[2] .+ :selfeff_mean_std .* β_control_med_full[3]
    :dependent = α_dep_full .+ :mediator .* β_med_dep_full .+ :age_std .* β_control_dep_full[1] .+ :sex_male_std .* β_control_dep_full[2] .+ :selfeff_mean_std .* β_control_dep_full[3]
end

α_med_full_media_type = df_full_media_type[2, :mean]
β_med_dep_full_media_type = df_full_media_type[1, :mean]
β_control_med_full_media_type = df_full_media_type[4:6, :mean]
α_dep_full_media_type = df_full_media_type[3, :mean]
β_med_dep_full = df_full_media_type[2, :mean]
β_control_dep_full_media_type = df_full_media_type[7:9, :mean]
β_media_type_med_full_media_type = df_full_media_type[10:13, :mean]

full_pred_media_type = @select df @astable begin
    :mediator = α_med_full_media_type .+
                :ftv_std .* β_media_type_med_full_media_type[1] .+
                :fnp_std .* β_media_type_med_full_media_type[2] .*
                :fsm_std .* β_media_type_med_full_media_type[3] .+
                :fmp_std .* β_media_type_med_full_media_type[4] .+
                :age_std .* β_control_med_full_media_type[1] .+
                :sex_male_std .* β_control_med_full_media_type[2] .+
                :selfeff_mean_std .* β_control_med_full_media_type[3]
    :dependent = α_dep_full_media_type .+
                 :mediator .* β_med_dep_full_media_type .+
                 :age_std .* β_control_dep_full_media_type[1] .+
                 :sex_male_std .* β_control_dep_full_media_type[2] .+
                 :selfeff_mean_std .* β_control_dep_full_media_type[3]
end

ŷ_full = full_pred[:, :dependent]
ŷ_full_media_type = full_pred_media_type[:, :dependent]

# Finally calculating the R2
function r2bayes(y, ŷ)
    return var(ŷ) / (var(ŷ) + var(y .- ŷ))
end

r2_full = r2bayes(y, ŷ_full)
r2_full_media_type = r2bayes(y, ŷ_full_media_type)