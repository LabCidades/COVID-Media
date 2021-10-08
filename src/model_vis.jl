using AlgebraOfGraphics
using CairoMakie
using DataFrames
using MCMCChains
using Serialization
using AlgebraOfGraphics: density
using DataFrames: stack

function save_figure(fig::Union{Figure, AlgebraOfGraphics.FigureGrid}, filename::String, prefix::String; quality=3)
    save(joinpath(pwd(), "figures", "$(prefix)_$(filename).png"), fig, px_per_unit=quality)
end

# Loading chains
date = "2021-10-08"
# m1
chn_m1 = deserialize(joinpath(pwd(), "chains", "m1_$date.jls"))

# subset chain only for β coeffs
subset_chn_m1 = MCMCChains.get_sections(chn_m1, :parameters)
df = select(DataFrame(subset_chn_m1), Not([:α, :σ]))
# df_all = DataFrame(subset_chn_all)
# df_tv = DataFrame(subset_chn_tv)
# df_np = DataFrame(subset_chn_np)
# df_sm = DataFrame(subset_chn_sm)
# df_all[!, :model] .= "all"
# df_tv[!, :model] .= "tv"
# df_np[!, :model] .= "np"
# df_sm[!, :model] .= "sm"

# df = vcat(df_all, df_tv, df_np, df_sm)
# iteration and chains are columns 1 and 2
long_df = stack(df, 3:ncol(df); variable_name=:parameter, value_name=:value)

plt_violin = data(long_df) *
                  mapping(:parameter,
                          :value)
                          # color=:model,
                          # dodge=:model) *
                  visual(Violin, show_median=true, width=0.95)

fig_violin = draw(plt_violin;
                  axis=(;
                        xticklabelrotation=π/4,
                        yticks=-3.0:0.5:3.0))

plt_boxplot = data(long_df) *
                   mapping(:parameter,
                           :value)
                           # color=:model,
                           # dodge=:model) *
                  visual(BoxPlot)

fig_boxplot = draw(plt_boxplot;
                   axis=(;
                         xticklabelrotation=π/4,
                         yticks=-3.0:0.5:3.0))

save_figure(fig_violin, "violin", "parameters")
save_figure(fig_boxplot, "boxplot", "parameters")
