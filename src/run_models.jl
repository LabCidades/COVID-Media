using Serialization
using Turing
using Dates: today

include(joinpath(pwd(), "src", "models.jl"))

numsamples = 2_000
nchains = 4

# test run models
test_mediation = sample(mediation, NUTS(), 50)
test_mediation_selfeff = sample(mediation_selfeff, NUTS(), 50)
test_full = sample(full, NUTS(), 50)
test_full_media_type = sample(full_media_type, NUTS(), 50)
test_interaction = sample(interaction, NUTS(), 50)
test_interaction_mediaexposure = sample(interaction_mediaexposure, NUTS(), 50)

# run model - WARNING! this might take a while
# 300s to 400s
chn_mediation = sample(mediation, NUTS(), MCMCThreads(), numsamples, nchains)
chn_mediation_selfeff = sample(mediation_selfeff, NUTS(), MCMCThreads(), numsamples, nchains)
chn_full = sample(full, NUTS(), MCMCThreads(), numsamples, nchains)
chn_full_media_type = sample(full_media_type, NUTS(), MCMCThreads(), numsamples, nchains)
chn_interaction = sample(interaction, NUTS(), MCMCThreads(), numsamples, nchains)
chn_interaction_mediaexposure = sample(interaction_mediaexposure, NUTS(), MCMCThreads(), numsamples, nchains)

# Saving chains
serialize(joinpath(pwd(), "chains", "mediation_$(today()).jls"), chn_mediation)
serialize(joinpath(pwd(), "chains", "mediation_selfeff_$(today()).jls"), chn_mediation_selfeff)
serialize(joinpath(pwd(), "chains", "full_$(today()).jls"), chn_full)
serialize(joinpath(pwd(), "chains", "full_media_type_$(today()).jls"), chn_full_media_type)
serialize(joinpath(pwd(), "chains", "interaction_$(today()).jls"), chn_interaction)
serialize(joinpath(pwd(), "chains", "interaction_mediaexposure_$(today()).jls"), chn_interaction_mediaexposure)

# all rhats okay
summarystats(chn_mediation)
summarystats(chn_mediation_selfeff)
summarystats(chn_full)
summarystats(chn_full_media_type)
summarystats(chn_interaction)
summarystats(chn_interaction_mediaexposure)
