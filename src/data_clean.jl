include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_raw.csv")
df = CSV.read(file, DataFrame)

clean_data!(df)

df |> CSV.write(joinpath(pwd(), "data", "responses_clean.csv"))
