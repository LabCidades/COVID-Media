using Serialization
using PrettyTables
using Dates: today

include(joinpath(pwd(), "src", "models.jl"))

numsamples = 2_000
nchains = 4
# run models - WARNING! this might take a while
test_full_chn = sample(full_all, NUTS(), 50) # test run
test_mediation_chn = sample(mediation_all, NUTS(), 50) # test run
# mediation - 400 to 500s per model
mediation_chn_all = sample(mediation_all, NUTS(), MCMCThreads(), numsamples, nchains)
mediation_chn_tv = sample(mediation_tv, NUTS(), MCMCThreads(), numsamples, nchains)
mediation_chn_np = sample(mediation_np, NUTS(), MCMCThreads(), numsamples, nchains)
mediation_chn_sm = sample(mediation_sm, NUTS(), MCMCThreads(), numsamples, nchains)
# full - 400 to 500s per model
full_chn_all = sample(full_all, NUTS(), MCMCThreads(), numsamples, nchains)
full_chn_tv = sample(full_tv, NUTS(), MCMCThreads(), numsamples, nchains)
full_chn_np = sample(full_np, NUTS(), MCMCThreads(), numsamples, nchains)
full_chn_sm = sample(full_sm, NUTS(), MCMCThreads(), numsamples, nchains)

# Saving chains
# mediation
serialize(joinpath(pwd(), "chains", "mediation_all_$(today()).jls"), mediation_chn_all)
serialize(joinpath(pwd(), "chains", "mediation_tv_$(today()).jls"), mediation_chn_tv)
serialize(joinpath(pwd(), "chains", "mediation_np_$(today()).jls"), mediation_chn_np)
serialize(joinpath(pwd(), "chains", "mediation_sm_$(today()).jls"), mediation_chn_sm)
# full
serialize(joinpath(pwd(), "chains", "full_all_$(today()).jls"), full_chn_all)
serialize(joinpath(pwd(), "chains", "full_tv_$(today()).jls"), full_chn_tv)
serialize(joinpath(pwd(), "chains", "full_np_$(today()).jls"), full_chn_np)
serialize(joinpath(pwd(), "chains", "full_sm_$(today()).jls"), full_chn_sm)

# Loading chains
date = today()
# mediation
mediation_chn_all = deserialize(joinpath(pwd(), "chains", "mediation_all_$date.jls"))
mediation_chn_tv = deserialize(joinpath(pwd(), "chains", "mediation_tv_$date.jls"))
mediation_chn_np = deserialize(joinpath(pwd(), "chains", "mediation_np_$date.jls"))
mediation_chn_sm = deserialize(joinpath(pwd(), "chains", "mediation_sm_$date.jls"))
# full
full_chn_all = deserialize(joinpath(pwd(), "chains", "full_all_$date.jls"))
full_chn_tv = deserialize(joinpath(pwd(), "chains", "full_tv_$date.jls"))
full_chn_np = deserialize(joinpath(pwd(), "chains", "full_np_$date.jls"))
full_chn_sm = deserialize(joinpath(pwd(), "chains", "full_sm_$date.jls"))

# all rhats okay
# mediation
summarystats(mediation_chn_all)
summarystats(mediation_chn_tv)
summarystats(mediation_chn_np)
summarystats(mediation_chn_sm)
# full
summarystats(full_chn_all)
summarystats(full_chn_tv)
summarystats(full_chn_np)
summarystats(full_chn_sm)

# quantiles
pretty_table(quantile(full_chn_all); nosubheader=true, formatters=ft_round(3), title="All Media Combined")
pretty_table(quantile(full_chn_tv); nosubheader=true, formatters=ft_round(3), title="Only TV")
pretty_table(quantile(full_chn_np); nosubheader=true, formatters=ft_round(3), title="Only Newspaper")
pretty_table(quantile(full_chn_sm); nosubheader=true, formatters=ft_round(3), title="Only Social Media")
