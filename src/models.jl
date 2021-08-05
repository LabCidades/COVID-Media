using Serialization
using Turing
using Dates: today
using Statistics: mean, std

include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

# control vars
control_vars = [:age, :sex_male, :marriage, :income]
control_df = select(df, control_vars)
# marriage dummy encoding
# single is the basal class
control_df.marriage_married = ifelse.(control_df.marriage .== 2, 1, 0)
control_df.marriage_divorced_widow = ifelse.(control_df.marriage .== 3, 1, 0)
control_matrix = select(control_df, Not(:marriage)) |> Matrix

@model function mediation(tv, newspaper, socialmedia, fear, protective_behaviors, control_vars)
    # priors
    # intercepts
    α_fear ~ LocationScale(mean(fear), 2.5 * std(fear), TDist(3))
    α_protective_behaviors ~ LocationScale(mean(protective_behaviors), 2.5 * std(protective_behaviors), TDist(3))
    # errors
    σ_fear ~ Exponential(1)
    σ_protective_behaviors ~ Exponential(1)
    # control vars
    β_control_vars ~ filldist(TDist(3), size(control_vars, 2))

    # coefficients
    media_exposure = tv + newspaper + socialmedia / 3
    β_media_exposure_direct ~ TDist(3)
    β_media_exposure_indirect ~ TDist(3)
    β_fear ~ TDist(3)

    # likelihood
    fear ~ MvNormal(α_fear .+ β_media_exposure_indirect * media_exposure, σ_fear)
    protective_behaviors ~ MvNormal(α_protective_behaviors .+
                                    β_media_exposure_direct * media_exposure .+
                                    β_fear * fear .+
                                    control_vars * β_control_vars,
                                    σ_protective_behaviors)

    return (; α_fear, α_protective_behaviors,
            σ_fear, σ_protective_behaviors,
            media_exposure,
            β_media_exposure_direct, β_media_exposure_indirect,
            β_fear,
            β_control_vars,
            fear, protective_behaviors)
end

# afra1 is yourself
# afra2 is close relative

model_mediation = mediation(df.ftv, df.fnp, df.fsm, df.fear_mean, df.be_mean, control_matrix)
chn_mediation = sample(model_mediation, NUTS(), MCMCThreads(), 2_000, 4)
# chn_mediation = sample(model_mediation, NUTS(), 50) # test run

# ab is β_fear * β_media_exposure_indirect
# c' is β_media_exposure_direct
ab_quantile = DataFrame(quantile(chn_mediation[[:β_fear, :β_media_exposure_indirect, :β_media_exposure_direct]]))
# row 2 is β_media_exposure_indirect and row 3 is β_fear
push!(ab_quantile, (
    :β_media_exposure_indirect_total,
    ab_quantile[2, 2] * ab_quantile[3, 2],
    ab_quantile[2, 3] * ab_quantile[3, 3],
    ab_quantile[2, 4] * ab_quantile[3, 4],
    ab_quantile[2, 5] * ab_quantile[3, 5],
    ab_quantile[2, 6] * ab_quantile[3, 6])
)

filter!(row -> row.parameters ∈ [:β_media_exposure_direct, :β_media_exposure_indirect_total], ab_quantile)

# Saving chains
serialize(joinpath(pwd(), "chains", "mediation_$(today()).jls"), chn_mediation)
