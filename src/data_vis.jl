using AlgebraOfGraphics
using CSV
using DataFrames

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)
