using CategoricalArrays
using CSV
using DataFrames
using Turing
using Statistics: mean, std
using Random: seed!

seed!(123)

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)
file_long = joinpath(pwd(), "data", "responses_clean_long.csv")
df_long = CSV.read(file_long, DataFrame)

# Varying-Intercept for media type
# ftv is 1
# fnp is 2
# fsm is 3
transform!(
    df_long,
    :media_type => x -> categorical(x; levels=["ftv", "fnp", "fsm", "fmp"]);
    renamecols=false,
)
transform!(df_long, :media_type => ByRow(levelcode) => :media_idx)

# Standard Scaler to μ=0 σ=1
function std_scaler(x::AbstractVector)
    return (x .- mean(x)) ./ std(x)
end
transform!(
    df,
    [
        :be_mean,
        :ftv,
        :fnp,
        :fsm,
        :fmp,
        :hmtime,
        :sex_male,
        :age,
        :fear_mean,
        :risk_mean,
        :selfeff_mean,
    ] .=>
        std_scaler .=> [
            :be_mean_std,
            :ftv_std,
            :fnp_std,
            :fsm_std,
            :fmp_std,
            :hmtime_std,
            :sex_male_std,
            :age_std,
            :fear_mean_std,
            :risk_mean_std,
            :selfeff_mean_std,
        ],
)
transform!(
    df_long,
    [
        :be_mean,
        :hmtime,
        :sex_male,
        :age,
        :fear_mean,
        :media_val,
        :risk_mean,
        :selfeff_mean,
    ] .=>
        std_scaler .=> [
            :be_mean_std,
            :hmtime_std,
            :sex_male_std,
            :age_std,
            :fear_mean_std,
            :media_val_std,
            :risk_mean_std,
            :selfeff_mean_std,
        ],
)

# media type
media_type = [:ftv_std, :fnp_std, :fsm_std, :fmp_std]
media_type_matrix = select(df, media_type) |> Matrix

# control vars
control_vars = [:age_std, :sex_male_std, :selfeff_mean_std]
control_interaction = [:age_std, :sex_male_std]
control_matrix = select(df, control_vars) |> Matrix
control_interaction_matrix = select(df, control_interaction) |> Matrix

@model function mediation_model(dependent, mediator, indep)
    # priors
    # intercepts
    α_med ~ TDist(3)
    α_dep ~ TDist(3)
    # errors
    σ_med ~ Exponential(1)
    σ_dep ~ Exponential(1)
    # coefficients
    β_indep_med ~ TDist(3)
    β_med_dep ~ TDist(3)
    β_indep_dep ~ TDist(3)
    # likelihood
    mediator ~ MvNormal(α_med .+ indep * β_indep_med, σ_med)
    dependent ~ MvNormal(α_dep .+ mediator * β_med_dep, σ_dep)
    # Mediation Tests
    # the direct path - c'
    direct = β_indep_dep
    # the indirect path - ab
    indirect = β_indep_med * β_med_dep
    # the total path - c' + ab
    total = direct + indirect
    return (; direct, indirect, total, dependent) # for predictive checks
end

@model function full_model(dependent, mediator, indep, control)
    # priors
    # intercepts
    α_med ~ TDist(3)
    α_dep ~ TDist(3)
    # errors
    σ_med ~ Exponential(1)
    σ_dep ~ Exponential(1)
    # coefficients
    β_indep_med ~ TDist(3)
    β_med_dep ~ TDist(3)
    β_control_med ~ filldist(TDist(3), size(control, 2))
    β_control_dep ~ filldist(TDist(3), size(control, 2))
    # likelihood
    mediator ~ MvNormal(α_med .+ indep * β_indep_med .+ control * β_control_med, σ_med)
    dependent ~ MvNormal(α_dep .+ mediator * β_med_dep .+ control * β_control_dep, σ_dep)
    return (;
        β_indep_med,
        β_med_dep,
        β_control_med,
        β_control_dep,
        α_med,
        α_dep,
        σ_dep,
        σ_med,
        dependent,  # for predictive checks
    )
end

@model function full_model_media_type(
    dependent, mediator, media_type, control
)
    # priors
    # intercepts
    α_med ~ TDist(3)
    α_dep ~ TDist(3)
    # errors
    σ_med ~ Exponential(1)
    σ_dep ~ Exponential(1)
    # coefficients
    β_med_dep ~ TDist(3)
    β_media_type_med ~ filldist(TDist(3), size(media_type, 2))
    β_control_med ~ filldist(TDist(3), size(control, 2))
    β_control_dep ~ filldist(TDist(3), size(control, 2))
    # likelihood
    mediator ~ MvNormal(α_med .+ media_type * β_media_type_med .+ control * β_control_med, σ_med)
    dependent ~ MvNormal(α_dep .+ mediator * β_med_dep .+ control * β_control_dep, σ_dep)
    return (;
        β_med_dep,
        β_media_type_med,
        β_control_med,
        β_control_dep,
        α_med,
        α_dep,
        σ_dep,
        σ_med,
        dependent,  # for predictive checks
    )
end

# interaction model
# fear*efficacy
@model function interaction_model(dependent, indep1, indep2, control)
    # priors
    # intercepts
    α ~ TDist(3)
    # errors
    σ ~ Exponential(1)
    # coefficients
    β_1 ~ TDist(3)
    β_2 ~ TDist(3)
    β_interaction ~ TDist(3)
    β_control ~ filldist(TDist(3), size(control, 2))
    # likelihood
    dependent ~ MvNormal(α .+ indep1 * β_1 .+ indep2 * β_2 .+ (β_interaction .* indep1 .* indep2) .+ control * β_control, σ)
    return (;
        β_1,
        β_2,
        β_interaction,
        β_control,
        α,
        σ,
        dependent,  # for predictive checks
    )
end

# instantiate models
mediation = mediation_model(df.be_mean_std, df.fear_mean_std, df.hmtime_std)
mediation_selfeff = mediation_model(df.be_mean_std, df.selfeff_mean_std, df.hmtime_std)
full = full_model(df.be_mean_std, df.fear_mean_std, df.hmtime_std, control_matrix)
full_media_type = full_model_media_type(
    df.be_mean_std,
    df.fear_mean_std,
    media_type_matrix,
    control_matrix,
)
interaction = interaction_model(df.be_mean_std, df.fear_mean_std, df.selfeff_mean_std, control_interaction_matrix)
interaction_mediaexposure = interaction_model(df.be_mean_std, df.hmtime_std, df.selfeff_mean_std, control_interaction_matrix)
