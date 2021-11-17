using CSV
using DataFrames
using Statistics: cov
using StatsBase: cronbachalpha

include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

# behaviors
# be01 to be20
label_behavior = []
covmatrix_behavior = cov(Matrix(select(df, Between(:be_01, :be_20))))
alpha_behavior = cronbachalpha(covmatrix_behavior).alpha

# fear
# afra1 and afra2
label_fear = [:afra1, :afra2]
covmatrix_fear = cov(Matrix(select(df, [:afra1, :afra2])))
alpha_fear = cronbachalpha(covmatrix_fear).alpha

# self-efficacy
# hb_b_se, hb_b_pse, hb_b_pbe, hb_a_pba (negative coded), hb_a_se
label_selfeff = [:hb_b_se, :hb_b_pse, :hb_b_pbe, :hb_a_pba, :hb_a_se]
covmatrix_selfeff = cov(Matrix(select(df, label_selfeff)))
alpha_selfeff = cronbachalpha(covmatrix_selfeff).alpha

CSV.write(
    joinpath(pwd(), "tables", "crombach_alphas.csv"),
    DataFrame(;
        vars=["behavior", "fear", "self-efficacy"],
        cronbach_alpha=[alpha_behavior, alpha_fear, alpha_selfeff],
    ),
)
