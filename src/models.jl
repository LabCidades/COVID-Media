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
    :media_type => x -> categorical(x; levels=["ftv", "fnp", "fsm"]);
    renamecols=false,
)
transform!(df_long, :media_type => ByRow(levelcode) => :media_idx)

# Standard Scaler to μ=0 σ=1
function std_scaler(x::AbstractVector)
    return (x .- mean(x)) ./ std(x)
end
transform!(
    df,
    [:be_mean, :ftv, :fnp, :fsm, :sex_male, :age, :fear_mean, :risk_mean, :selfeff_mean] .=>
        std_scaler .=> [
            :be_mean_std,
            :ftv_std,
            :fnp_std,
            :fsm_std,
            :sex_male_std,
            :age_std,
            :fear_mean_std,
            :risk_mean_std,
            :selfeff_mean_std,
        ],
)
transform!(
    df_long,
    [:be_mean, :sex_male, :age, :fear_mean, :media_val, :risk_mean, :selfeff_mean] .=>
        std_scaler .=> [
            :be_mean_std,
            :sex_male_std,
            :age_std,
            :fear_mean_std,
            :media_val_std,
            :risk_mean_std,
            :selfeff_mean_std,
        ],
)

# control vars
control_vars = [:age_std, :sex_male_std, :selfeff_mean_std]
control_matrix = select(df, control_vars) |> Matrix
control_matrix_long = select(df_long, control_vars) |> Matrix

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

@model function full_model(
    dependent, mediator, indep, idx, control; n_gr=length(unique(idx))
)
    # priors
    # intercepts
    α_med ~ TDist(3)
    α_dep ~ TDist(3)
    # variance of random intercepts
    τ_med ~ truncated(Cauchy(0, 2), 0, Inf) # group-level SDs intercepts
    z_med_j ~ filldist(Normal(0, 1), n_gr)  # NCP group-level intercepts
    α_med_j = z_med_j .* τ_med              # group-level intercepts
    # errors
    σ_med ~ Exponential(1)
    σ_dep ~ Exponential(1)
    # coefficients
    β_indep_med ~ TDist(3)
    β_med_dep ~ TDist(3)
    β_control ~ filldist(TDist(3), size(control, 2))
    # likelihood
    mediator ~ MvNormal(α_med .+ α_med_j[idx] .+ indep * β_indep_med, σ_med)
    dependent ~ MvNormal(α_dep .+ mediator * β_med_dep .+ control * β_control, σ_dep)
    return (;
        β_indep_med,
        β_med_dep,
        β_control,
        α_med,
        α_dep,
        α_med_j,
        τ_med,
        σ_dep,
        σ_med,
        dependent,  # for predictive checks
    )
end

# instantiate models
mediation = mediation_model(
    df.be_mean_std, df.risk_mean_std, ((df.ftv_std .+ df.fnp_std .+ df.fsm_std) ./ 3)
)
full = full_model(
    df_long.be_mean_std,
    df_long.risk_mean_std,
    df_long.media_val_std,
    df_long.media_idx,
    control_matrix_long,
)
