using CSV
using DataFrames
using LinearAlgebra: Diagonal
using Statistics: cov

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

"""
Calculate Crombach's Alpha (1951) according to the Wikipedia formula:
https://en.wikipedia.org/wiki/Cronbach%27s_alpha
"""
function crombach(covmatrix::AbstractMatrix{T}) where T <: Real
    k = size(covmatrix, 2)
    σ = sum(covmatrix)
    σ_ij = sum(covmatrix - Diagonal(covmatrix)) / (k * (k - 1))
    ρ = k^2 * σ_ij / σ
    return ρ
end

labels = [:hb_p_pbe, :hb_a_pbe, :hb_b_se, :hb_a_se]
covmatrix = cov(Matrix(select(df, labels)))

crombach(covmatrix)
