using Serialization
using PrettyTables
using Dates: today

include(joinpath(pwd(), "src", "models.jl"))

numsamples = 2_000
nchains = 4

# test run model
test_full = sample(full, NUTS(), 50)

# run model - WARNING! this might take a while
# 900s to 1,000s
chn_full = sample(full, NUTS(), MCMCThreads(), numsamples, nchains)

# Saving chains
serialize(joinpath(pwd(), "chains", "model_$(today()).jls"), chn_full)

# all rhats okay
summarystats(chn_full)
