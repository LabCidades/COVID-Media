using CSV
using DataFrames
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

@model function mediation_model(dependent, mediator, indep, control)
    # priors
    # intercepts
    α_med ~ LocationScale(mean(mediator), 2.5 * std(mediator), TDist(3))
    α_dep ~ LocationScale(mean(dependent), 2.5 * std(dependent), TDist(3))

    # errors
    σ_med ~ Exponential(1)
    σ_dep ~ Exponential(1)

    # control vars
    β_control_med ~ filldist(TDist(3), size(control, 2))
    β_control_dep ~ filldist(TDist(3), size(control, 2))

    # coefficients
    β_med ~ TDist(3)
    β_dep ~ TDist(3)

    # likelihood
    mediator ~ MvNormal(α_med .+ indep * β_med .+ control * β_control_med, σ_med)
    dependent ~ MvNormal(α_dep .+ indep * β_dep .+ control * β_control_dep, σ_dep)

    # Mediation Tests
    # the direct path - c'
    direct = abs(β_dep)
     # the indirect path - ab
    indirect = abs(β_med * β_dep)
    # the total path - c' + ab
    total = direct + indirect
    
    return (; direct, indirect, total)
end

@model function full_model(dependent, X, control)
    # priors
    # intercept
    α ~ LocationScale(mean(dependent), 2.5 * std(dependent), TDist(3))

    # error
    σ ~ Exponential(1)

    # control vars
    β_control ~ filldist(TDist(3), size(control, 2))

    # coefficients
    β ~ filldist(TDist(3), size(X, 2))

    # likelihood
    dependent ~ MvNormal(α .+ X * β .+ control * β_control, σ)
    return (; dependent) # for predictive checks
end

# instantiate models
# mediation
mediation_all = mediation_model(df.be_mean, df.fear_mean, (df.ftv .+ df.fnp .+ df.fsm ./ 3), control_matrix)
mediation_tv = mediation_model(df.be_mean, df.fear_mean, df.ftv, control_matrix)
mediation_np = mediation_model(df.be_mean, df.fear_mean, df.fnp, control_matrix)
mediation_sm = mediation_model(df.be_mean, df.fear_mean, df.fsm, control_matrix)

function make_X(indep::Symbol; df::DataFrame=df, type::AbstractString="single")
    # X Matrix
    # Independent + Moderators
    # Hierarchy Principle: both main effects and also interactions
    if type == "single"
        indep = df[!, indep]
    elseif type == "all"
        indep = (df.ftv .+ df.fnp .+ df.fsm) ./ 3
    end
    moderator_vars = [:fear_mean, :risk_mean, :selfeff_mean]
    df_moderator = select(df, moderator_vars)
    moderator_matrix = select(df, moderator_vars) |> Matrix
    interaction_matrix = transform(df_moderator, moderator_vars .=> x -> x .* indep;
                                   renamecols=false) |> Matrix
    return hcat(Vector(indep), moderator_matrix, interaction_matrix)
end

# full
full_all = full_model(df.be_mean, make_X(:all; type="all"), control_matrix)
full_tv = full_model(df.be_mean, make_X(:ftv), control_matrix)
full_np = full_model(df.be_mean, make_X(:fnp), control_matrix)
full_sm = full_model(df.be_mean, make_X(:fsm), control_matrix)
