include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

labels = [:hb_p_pbe, :hb_a_pbe, :hb_b_se, :hb_a_se]
covmatrix = cov(Matrix(select(df, labels)))

crombach(covmatrix)
