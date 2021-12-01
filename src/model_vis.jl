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
date = "2021-11-18"
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))
chn_full_long = deserialize(joinpath(pwd(), "chains", "full_long_$date.jls"))

# subset chain only for β coeffs and α intercepts
gen_full = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
gen_full_long = generated_quantities(
    full_long, MCMCChains.get_sections(chn_full_long, :parameters)
)

# full long_df
df_long = reduce(vcat, DataFrame(gen_full_long[:, i]) for i in 1:size(gen_full_long, 2))
select!(df_long, Not([:dependent, :τ_med, :σ_dep, :σ_med]))
df_long = select(
    transform(df_long, :β_control_med => AsTable),
    Not(:β_control_med),
    [:x1, :x2, :x3] .=> ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
)
select!(df_long, Not([:x1, :x2, :x3]))
df_long = select(
    transform(df_long, :β_control_dep => AsTable),
    Not(:β_control_dep),
    [:x1, :x2, :x3] .=> ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
)
select!(df_long, Not([:x1, :x2, :x3]))
df_long = select(
    transform(df_long, :α_med_j => AsTable),
    Not(:α_med_j),
    [:x1, :x2, :x3, :x4] .=> ["α_med_j[1]", "α_med_j[2]", "α_med_j[3]", "α_med_j[4]"],
)
select!(df_long, 1:3, names(df_long, r"^β_control"), names(df_long, r"^α"), :)
select!(df_long, Not([:x1, :x2, :x3, :x4]))

# full df
df = reduce(vcat, DataFrame(gen_full[:, i]) for i in 1:size(gen_full, 2))
select!(df, Not([:dependent, :σ_dep, :σ_med]))
df = select(
    transform(df, :β_control_med => AsTable),
    Not(:β_control_med),
    [:x1, :x2, :x3] .=> ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
)
select!(df, Not([:x1, :x2, :x3]))
df = select(
    transform(df, :β_control_dep => AsTable),
    Not(:β_control_dep),
    [:x1, :x2, :x3] .=> ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
)
select!(df, Not([:x1, :x2, :x3]))
select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)

# Model visualization functions
function model_vis_long(df)
    df_stacked = stack(df, 1:ncol(df); variable_name=:parameter, value_name=:value)
    xticks = [
        "α_dep",
        "α_med",
        "α_fear_tv",
        "α_fear_np",
        "α_fear_sm",
        "α_fear_mp",
        "β_control_dep_age",
        "β_control_dep_sex_male",
        "β_control_dep_selfeff",
        "β_control_med_age",
        "β_control_med_sex_male",
        "β_control_med_selfeff",
        "β_med_dep",
    ]
    plt =
        data(df_stacked) *
        mapping(:parameter, :value) *
        # color=:model,
        # dodge=:model) *
        visual(BoxPlot; show_outliers=false, width=0.95, whiskerlinewidth=2)
    fig = draw(plt; axis=(;
        xticks=(1:length(xticks), xticks),
        xticklabelrotation=π / 4,
        yticks=-1.0:0.1:1.0,
        #limits=(nothing, (-0.5, 0.5)),
    ))
    return fig
end

function model_vis(df)
    df_stacked = stack(df, 1:ncol(df); variable_name=:parameter, value_name=:value)
    xticks = [
        "α_dep",
        "α_med",
        "β_control_dep_age",
        "β_control_dep_sex_male",
        "β_control_dep_selfeff",
        "β_control_med_age",
        "β_control_med_sex_male",
        "β_control_med_selfeff",
        "β_indep_med",
        "β_med_dep",
    ]
    plt =
        data(df_stacked) *
        mapping(:parameter, :value) *
        # color=:model,
        # dodge=:model) *
        visual(BoxPlot; show_outliers=false, width=0.95, whiskerlinewidth=2)
    fig = draw(
        plt;
        axis=(;
            xticks=(1:length(xticks), xticks),
            xticklabelrotation=π / 4,
            yticks=-1.0:0.1:1.0,
            #limits=(nothing, (-0.5, 0.5)),
        ),
    )
    return fig
end

save_figure(model_vis(df), "boxplot", "parameters")
save_figure(model_vis_long(df_long), "boxplot", "parameters_long")
