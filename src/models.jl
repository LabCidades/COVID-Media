using PrettyTables
using Turing
using Statistics: mean, std

include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

@model function mediation(tv, newspaper, socialmedia, fear, protective_behaviors)
    # priors
    # intercepts
    α_fear ~ Normal(mean(fear), 2.5 * std(fear))
    α_protective_behaviors ~ Normal(mean(protective_behaviors), 2.5 * std(protective_behaviors))
    # errors
    σ_fear ~ Exponential(1)
    σ_protective_behaviors ~ Exponential(1)

    # coefficients
    media_exposure = tv + newspaper + socialmedia
    β_media_exposure_direct ~ Normal(0, 2)
    β_media_exposure_indirect ~ Normal(0, 2)
    β_fear ~ Normal(0, 2)

    # likelihood
    fear ~ MvNormal(α_fear .+ β_media_exposure_indirect * media_exposure, σ_fear)
    protective_behaviors ~ MvNormal(α_protective_behaviors .+
                                    β_media_exposure_direct * media_exposure .+
                                    β_fear * fear, σ_protective_behaviors)

    return (; α_fear, α_protective_behaviors,
            σ_fear, σ_protective_behaviors,
            media_exposure,
            β_media_exposure_direct, β_media_exposure_indirect,
            β_fear,
            fear, protective_behaviors)
end

# afra1 is yourself
# afra2 is close relative

model_mediation = mediation(df.ftv, df.fnp, df.fsm, df.afra1, df.be_sum)
chn_mediation = sample(model_mediation, NUTS(), MCMCThreads(), 2_000, 4)

# ab is β_fear * β_media_exposure_indirect
# c' is β_media_exposure_direct
ab_quantile = DataFrame(quantile(chn_mediation[[:β_fear, :β_media_exposure_indirect, :β_media_exposure_direct]]))
push!(ab_quantile, (
    :β_media_exposure_indirect_total,
    ab_quantile[2, 2] * ab_quantile[3, 2],
    ab_quantile[2, 3] * ab_quantile[3, 3],
    ab_quantile[2, 4] * ab_quantile[3, 4],
    ab_quantile[2, 5] * ab_quantile[3, 5],
    ab_quantile[2, 6] * ab_quantile[3, 6])
)

filter!(row -> row.parameters ∈ [:β_media_exposure_direct, :β_media_exposure_indirect_total], ab_quantile)

ab_quantile
