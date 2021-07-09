using CSV
using DataFrames

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

function make_summary(df::DataFrame)
    return describe(df, :mean, :std, :min, :q25, :median, :q75, :max, :nmissing)
end

make_summary(df) |> CSV.write(joinpath(pwd(), "tables", "summarystats.csv"))
