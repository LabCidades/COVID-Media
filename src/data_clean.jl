using CSV
using DataFrames
include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_raw.csv")
df = CSV.read(file, DataFrame)

clean_data!(df)

df |> CSV.write(joinpath(pwd(), "data", "responses_clean.csv"))

select!(df, :age, :sex_male,
        :ftv, :fnp, :fsm,
        names(df, r"mean$"))

DataFrames.stack(df, [:ftv, :fnp, :fsm];
                 variable_name=:media_type,
                 value_name=:media_val) |> CSV.write(joinpath(pwd(),
                                                              "data",
                                                              "responses_clean_long.csv"
                                                             ))
