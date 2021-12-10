using Serialization
using Turing
using Dates: today

include(joinpath(pwd(), "src", "models.jl"))

numsamples = 2_000
nchains = 4

# test run models
test_mediation = sample(mediation, NUTS(), 50)
test_full = sample(full, NUTS(), 50)
test_full_media_type = sample(full_media_type, NUTS(), 50)

# run model - WARNING! this might take a while
# 300s to 400s
chn_mediation = sample(mediation, NUTS(), MCMCThreads(), numsamples, nchains)
chn_full = sample(full, NUTS(), MCMCThreads(), numsamples, nchains)
chn_full_media_type = sample(full_media_type, NUTS(), MCMCThreads(), numsamples, nchains)

# Saving chains
serialize(joinpath(pwd(), "chains", "mediation_$(today()).jls"), chn_mediation)
serialize(joinpath(pwd(), "chains", "full_$(today()).jls"), chn_full)
serialize(joinpath(pwd(), "chains", "full_media_type_$(today()).jls"), chn_full_media_type)

# all rhats okay
summarystats(chn_mediation)
summarystats(chn_full)
summarystats(chn_full_media_type)
