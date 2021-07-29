using CSV
using DataFrames

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

describe(df, :mean, :std, :min, :q25, :median, :q75, :max, :nmissing) |> CSV.write(joinpath(pwd(), "tables", "summarystats.csv"))
