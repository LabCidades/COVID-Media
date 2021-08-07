using AlgebraOfGraphics
using CairoMakie
using DataFrames
using MCMCChains
using Serialization
using AlgebraOfGraphics: density

function save_figure(fig::Union{Figure, AlgebraOfGraphics.FigureGrid}, filename::String, prefix::String; quality=3)
    save(joinpath(pwd(), "figures", "$(prefix)_$(filename).png"), fig, px_per_unit=quality)
end

# Loading chains
date = "2021-08-07"
# full
full_chn_all = deserialize(joinpath(pwd(), "chains", "full_all_$date.jls"))
full_chn_tv = deserialize(joinpath(pwd(), "chains", "full_tv_$date.jls"))
full_chn_np = deserialize(joinpath(pwd(), "chains", "full_np_$date.jls"))
full_chn_sm = deserialize(joinpath(pwd(), "chains", "full_sm_$date.jls"))

# subset chains only for β coeffs
subset_chn_all = MCMCChains.get_sections(full_chn_all, :parameters)[ ["β_fear[$i]" for i ∈ 1:3] ∪ ["β_behaviors[$i]" for i ∈ 1:3] ]
subset_chn_tv = MCMCChains.get_sections(full_chn_tv, :parameters)[ ["β_fear[$i]" for i ∈ 1:3] ∪ ["β_behaviors[$i]" for i ∈ 1:3] ]
subset_chn_np = MCMCChains.get_sections(full_chn_np, :parameters)[ ["β_fear[$i]" for i ∈ 1:3] ∪ ["β_behaviors[$i]" for i ∈ 1:3] ]
subset_chn_sm = MCMCChains.get_sections(full_chn_sm, :parameters)[ ["β_fear[$i]" for i ∈ 1:3] ∪ ["β_behaviors[$i]" for i ∈ 1:3] ]
df_all = DataFrame(subset_chn_all)
df_tv = DataFrame(subset_chn_tv)
df_np = DataFrame(subset_chn_np)
df_sm = DataFrame(subset_chn_sm)
df_all[!, :model] .= "all"
df_tv[!, :model] .= "tv"
df_np[!, :model] .= "np"
df_sm[!, :model] .= "sm"

df = vcat(df_all, df_tv, df_np, df_sm)
long_df = stack(df, Between("β_fear[1]", "β_behaviors[3]"); variable_name=:parameter, value_name=:value)

plt_violin = data(long_df) *
                  mapping(:parameter,
                          :value;
                          color=:model,
                          dodge=:model) *
                  visual(Violin, show_median=true, width=0.95)

fig_violin = draw(plt_violin;
                  axis=(;
                        xticklabelrotation=π/4,
                        yticks=-0.2:0.05:0.2))

plt_boxplot = data(long_df) *
                   mapping(:parameter,
                           :value;
                           color=:model,
                           dodge=:model) *
                  visual(BoxPlot)

fig_boxplot = draw(plt_boxplot;
                   axis=(;
                         xticklabelrotation=π/4,
                         yticks=-0.2:0.05:0.2))

save_figure(fig_violin, "violin", "parameters")
save_figure(fig_boxplot, "boxplot", "parameters")
