using Turing
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

@model function mediation_model(behaviors, media, fear, risk, selfeff, control)
    # priors
    # intercepts
    α_fear ~ LocationScale(mean(fear), 2.5 * std(fear), TDist(3))
    α_behaviors ~ LocationScale(mean(behaviors), 2.5 * std(behaviors), TDist(3))

    # errors
    σ_fear ~ Exponential(1)
    σ_behaviors ~ Exponential(1)

    # control vars
    β_control_fear ~ filldist(TDist(3), size(control, 2))
    β_control_behaviors ~ filldist(TDist(3), size(control, 2))

    # coefficients
    β_fear ~ filldist(TDist(3), 2)
    β_behaviors ~ filldist(TDist(3), 3)

    # likelihood
    # X matrices
    X_fear = Matrix([media risk ])
    X_behaviors = Matrix([media fear selfeff])

    # dependent vars
    fear ~ MvNormal(α_fear .+
                    X_fear * β_fear .+
                    control * β_control_fear, σ_fear)
    behaviors ~ MvNormal(α_behaviors .+
                         X_behaviors * β_behaviors .+
                         control * β_control_behaviors,
                         σ_behaviors)

    return (; media_direct = β_behaviors[1],                               # the direct path - c'
              media_indirect = β_fear[1] * β_behaviors[2],                 # the indirect path - ab
              media_total = β_behaviors[1] + (β_fear[1] * β_behaviors[2])) # the total path - c' + ab
end

@model function full_model(behaviors, media, fear, risk, selfeff, control)
    # priors
    # intercepts
    α_fear ~ LocationScale(mean(fear), 2.5 * std(fear), TDist(3))
    α_behaviors ~ LocationScale(mean(behaviors), 2.5 * std(behaviors), TDist(3))

    # errors
    σ_fear ~ Exponential(1)
    σ_behaviors ~ Exponential(1)

    # control vars
    β_control_fear ~ filldist(TDist(3), size(control, 2))
    β_control_behaviors ~ filldist(TDist(3), size(control, 2))

    # coefficients
    β_fear ~ filldist(TDist(3), 3)
    β_behaviors ~ filldist(TDist(3), 3)

    # likelihood
    # X matrices
    X_fear = Matrix([media risk (media .* risk)])
    X_behaviors = Matrix([fear selfeff (fear .* selfeff)])

    # dependent vars
    fear ~ MvNormal(α_fear .+
                    X_fear * β_fear .+
                    control * β_control_fear, σ_fear)
    behaviors ~ MvNormal(α_behaviors .+
                         X_behaviors * β_behaviors .+
                         control * β_control_behaviors,
                         σ_behaviors)

    return (; fear, behaviors) # for predictive checks
end

# instantiate models
# mediation
mediation_all = mediation_model(df.be_mean, (df.ftv .+ df.fnp .+ df.fsm ./ 3), df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
mediation_tv = mediation_model(df.be_mean, df.ftv, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
mediation_np = mediation_model(df.be_mean, df.fnp, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
mediation_sm = mediation_model(df.be_mean, df.fsm, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
# full
full_all = full_model(df.be_mean, (df.ftv .+ df.fnp .+ df.fsm ./ 3), df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
full_tv = full_model(df.be_mean, df.ftv, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
full_np = full_model(df.be_mean, df.fnp, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
full_sm = full_model(df.be_mean, df.fsm, df.fear_mean, df.risk_mean, df.selfeff_mean, control_matrix)
