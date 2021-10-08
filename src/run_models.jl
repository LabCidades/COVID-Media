using Serialization
using PrettyTables
using Dates: today

include(joinpath(pwd(), "src", "models.jl"))

numsamples = 2_000
nchains = 4

# run models - WARNING! this might take a while
# test_full_chn = sample(full_all, NUTS(), 50) # test run
# test_mediation_chn = sample(mediation, NUTS(), 50) # test run
test_m1 = sample(m1, NUTS(), 50) # test run

# mediation - 400 to 500s per model
# mediation_chn = sample(mediation, NUTS(), MCMCThreads(), numsamples, nchains)

# full_chn_all = sample(full_all, NUTS(), MCMCThreads(), numsamples, nchains)
# full_chn_tv = sample(full_tv, NUTS(), MCMCThreads(), numsamples, nchains)
# full_chn_np = sample(full_np, NUTS(), MCMCThreads(), numsamples, nchains)
# full_chn_sm = sample(full_sm, NUTS(), MCMCThreads(), numsamples, nchains)
chn_m1 = sample(m1, NUTS(), MCMCThreads(), numsamples, nchains)

# Saving chains
# mediation
# serialize(joinpath(pwd(), "chains", "mediation_$(today()).jls"), mediation_chn)

# full
# serialize(joinpath(pwd(), "chains", "full_all_$(today()).jls"), full_chn_all)
# serialize(joinpath(pwd(), "chains", "full_tv_$(today()).jls"), full_chn_tv)
# serialize(joinpath(pwd(), "chains", "full_np_$(today()).jls"), full_chn_np)
# serialize(joinpath(pwd(), "chains", "full_sm_$(today()).jls"), full_chn_sm)
serialize(joinpath(pwd(), "chains", "m1_$(today()).jls"), chn_m1)

# Loading chains
date = today()

# mediation
# mediation_chn = deserialize(joinpath(pwd(), "chains", "mediation_$date.jls"))

# # full
# full_chn_all = deserialize(joinpath(pwd(), "chains", "full_all_$date.jls"))
# full_chn_tv = deserialize(joinpath(pwd(), "chains", "full_tv_$date.jls"))
# full_chn_np = deserialize(joinpath(pwd(), "chains", "full_np_$date.jls"))
# full_chn_sm = deserialize(joinpath(pwd(), "chains", "full_sm_$date.jls"))
chn_m1 = deserialize(joinpath(pwd(), "chains", "m1_$date.jls"))

# all rhats okay
# mediation
# summarystats(mediation_chn)

# # full
# summarystats(full_chn_all)
# summarystats(full_chn_tv)
# summarystats(full_chn_np)
# summarystats(full_chn_sm)
summarystats(chn_m1)

# quantiles
# pretty_table(quantile(full_chn_all); nosubheader=true, formatters=ft_round(3), title="All Media Combined")
# pretty_table(quantile(full_chn_tv); nosubheader=true, formatters=ft_round(3), title="Only TV")
# pretty_table(quantile(full_chn_np); nosubheader=true, formatters=ft_round(3), title="Only Newspaper")
# pretty_table(quantile(full_chn_sm); nosubheader=true, formatters=ft_round(3), title="Only Social Media")
pretty_table(quantile(chn_m1);
             nosubheader=true, alignment=:l,
             formatters=ft_round(3), linebreaks=true,
             title="Model 1")
