using AlgebraOfGraphics
using CairoMakie
using DataFrames
using MCMCChains
using Serialization
using AlgebraOfGraphics: density
using DataFrames: stack

include(joinpath(pwd(), "src", "models.jl"))

function save_figure(
    fig::Union{Figure,AlgebraOfGraphics.FigureGrid},
    filename::String,
    prefix::String;
    quality=3,
)
    return save(
        joinpath(pwd(), "figures", "$(prefix)_$(filename).png"), fig; px_per_unit=quality
    )
end

# Loading chains
date = "2021-10-15"
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))

# subset chain only for β coeffs and α intercepts
gen = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
df = reduce(vcat, DataFrame(gen[:, i]) for i in 1:size(gen, 2))
select!(df, Not([:dependent, :τ_med, :σ_dep, :σ_med]))
df = select(
    transform(df, :β_control => AsTable),
    Not(:β_control),
    [:x1, :x2, :x3] .=> ["β_control[1]", "β_control[2]", "β_control[3]"],
)
df = select(
    transform(df, :α_med_j => AsTable),
    Not(:α_med_j),
    [:x1, :x2, :x3] .=> ["α_med_j[1]", "α_med_j[2]", "α_med_j[3]"],
)
select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
select!(df, Not([:x1, :x2, :x3]))

# Convert to long format
long_df = stack(df, 1:ncol(df); variable_name=:parameter, value_name=:value)

xticks = [
    "α_beh",
    "α_risk",
    "α_risk_tv",
    "α_risk_np",
    "α_risk_sm",
    "β_age",
    "β_sex_male",
    "β_selfeff",
    "β_media_risk",
    "β_risk_beh",
]

plt_violin =
    data(long_df) *
    mapping(:parameter, :value) *
    # color=:model,
    # dodge=:model) *
    visual(Violin; show_outliers=false, show_median=true, width=0.95)


plt_boxplot =
    data(long_df) *
    mapping(:parameter, :value) *
    # color=:model,
    # dodge=:model) *
    visual(BoxPlot; show_outliers=false)

fig_violin = draw(
    plt_violin;
    axis=(;
        xticks=(1:length(xticks), xticks),
        xticklabelrotation=π / 4,
        yticks=-1.0:0.1:1.0,
        #limits=(nothing, (-0.5, 0.5)),
    ),
)

fig_boxplot = draw(
    plt_boxplot;
    axis=(;
        #xticks=(1:length(xticks), xticks),
        xticklabelrotation=π / 4,
        yticks=-1.0:0.1:1.0,
        #limits=(nothing, (-0.5, 0.5)),
    ),
)

save_figure(fig_violin, "violin", "parameters")
save_figure(fig_boxplot, "boxplot", "parameters")
