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
date = "2022-06-07"
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))
chn_full_media_type = deserialize(joinpath(pwd(), "chains", "full_media_type_$date.jls"))

# subset chain only for β coeffs and α intercepts
gen_full = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
gen_full_media_type = generated_quantities(
    full_media_type, MCMCChains.get_sections(chn_full_media_type, :parameters)
)

# df transformations
# full
df_full = reduce(vcat, DataFrame(gen_full[:, i]) for i in 1:size(gen_full, 2))
select!(df_full, Not([:dependent, :σ_dep, :σ_med]))
df_full = select(
    transform(df_full, :β_control_med => AsTable),
    Not(:β_control_med),
    [:x1, :x2, :x3] .=> ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
)
select!(df_full, Not([:x1, :x2, :x3]))
df_full = select(
    transform(df_full, :β_control_dep => AsTable),
    Not(:β_control_dep),
    [:x1, :x2, :x3] .=> ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
)
select!(df_full, Not([:x1, :x2, :x3]))
select!(df_full, 1:3, names(df_full, r"^β_control"), names(df_full, r"^α"), :)

# full_media_type
df_full_media_type = reduce(vcat, DataFrame(gen_full_media_type[:, i]) for i in 1:size(gen_full_media_type, 2))
select!(df_full_media_type, Not([:dependent, :σ_dep, :σ_med]))
df_full_media_type = select(
    transform(df_full_media_type, :β_media_type_med => AsTable),
    Not(:β_media_type_med),
    [:x1, :x2, :x3, :x4] .=> ["β_media_type_med[1]", "β_media_type_med[2]", "β_media_type_med[3]", "β_media_type_med[4]"],
)
select!(df_full_media_type, Not([:x1, :x2, :x3, :x4]))
df_full_media_type = select(
    transform(df_full_media_type, :β_control_med => AsTable),
    Not(:β_control_med),
    [:x1, :x2, :x3] .=> ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
)
select!(df_full_media_type, Not([:x1, :x2, :x3]))
df_full_media_type = select(
    transform(df_full_media_type, :β_control_dep => AsTable),
    Not(:β_control_dep),
    [:x1, :x2, :x3] .=> ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
)
select!(df_full_media_type, Not([:x1, :x2, :x3]))
select!(df_full_media_type, 1:3, names(df_full_media_type, r"^β_control"), names(df_full_media_type, r"^α"), :)

# Model visualization functions
function model_vis_media_type(df)
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
        "β_med_dep",
        "β_tv_fear",
        "β_np_fear",
        "β_sm_fear",
        "β_mp_fear",
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

save_figure(model_vis(df_full), "boxplot", "parameters")
save_figure(model_vis_media_type(df_full_media_type), "boxplot", "parameters_media_type")
