using Statistics: cov
using StatsBase: cronbachalpha

include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

# perceived risk
labels_risk = [:hb_b_psu, :hb_b_pse, :hb_a_psu, :hb_a_pse]
covmatrix_risk = cov(Matrix(select(df, labels_risk)))
cronbachalpha(covmatrix_risk)

# self-efficacy
# hb_b_se, hb_b_pse, hb_b_pbe, hb_a_pba (negative coded), hb_a_se
label_selfeff = [:hb_b_se, :hb_b_pse, :hb_b_pbe, :hb_a_pba, :hb_a_se]
covmatrix_selfeff = cov(Matrix(select(df, label_selfeff)))
cronbachalpha(covmatrix_selfeff)
