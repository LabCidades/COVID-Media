using CSV
using DataFrames
using Serialization
using PrettyTables
using Turing

include(joinpath(pwd(), "src", "models.jl"))

function make_df(x::Matrix; type, dependent=false)
    df = reduce(vcat, DataFrame(x[:, i]) for i in 1:size(x, 2))
    if !dependent
        select!(df, Not(:dependent))
    end
    if type == "full_media_type"
        df = select(
            transform(df, :β_control_med => AsTable),
            Not(:β_control_med),
            [:x1, :x2, :x3] .=>
                ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_control_dep => AsTable),
            Not(:β_control_dep),
            [:x1, :x2, :x3] .=>
                ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_media_type_med => AsTable),
            Not(:β_media_type_med),
            [:x1, :x2, :x3, :x4] .=>
                ["β_media_type_med[1]", "β_media_type_med[2]", "β_media_type_med[3]", "β_media_type_med[4]"],
        )
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^β_media_type_med"), :)
        select!(df, Not([:x1, :x2, :x3, :x4]))
    elseif type == "full"
        df = select(
            transform(df, :β_control_med => AsTable),
            Not(:β_control_med),
            [:x1, :x2, :x3] .=>
                ["β_control_med[1]", "β_control_med[2]", "β_control_med[3]"],
        )
        select!(df, Not([:x1, :x2, :x3]))
        df = select(
            transform(df, :β_control_dep => AsTable),
            Not(:β_control_dep),
            [:x1, :x2, :x3] .=>
                ["β_control_dep[1]", "β_control_dep[2]", "β_control_dep[3]"],
        )
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
        select!(df, Not([:x1, :x2, :x3]))
    elseif type == "interaction"
        df = select(
            transform(df, :β_control => AsTable),
            Not(:β_control),
            [:x1, :x2] .=>
                ["β_control[1]", "β_control[2]"],
        )
        select!(df, Not([:x1, :x2,]))
        select!(df, 1:3, names(df, r"^β_control"), names(df, r"^α"), :)
    end
    summ = describe(
        df,
        :mean,
        :std,
        :median,
        (x -> quantile(x, 0.025)) => :q025,
        (x -> quantile(x, 0.975)) => :q975,
    )
    return summ
end

function make_summary(x::AbstractMatrix, title::AbstractString; type, dependent=false)
    summ = make_df(x; type, dependent)
    return pretty_table(
        summ;
        nosubheader=true,
        alignment=:l,
        formatters=ft_round(3),
        linebreaks=true,
        title=title,
    )
end

# Loading chains
date = "2021-11-18"
chn_mediation = deserialize(joinpath(pwd(), "chains", "mediation_$date.jls"))
chn_full = deserialize(joinpath(pwd(), "chains", "full_$date.jls"))
chn_full_media_type = deserialize(joinpath(pwd(), "chains", "full_media_type_$date.jls"))

# generating table
gen_mediation = generated_quantities(
    mediation, MCMCChains.get_sections(chn_mediation, :parameters)
)
gen_full = generated_quantities(full, MCMCChains.get_sections(chn_full, :parameters))
gen_full_media_type = generated_quantities(
    full_media_type, MCMCChains.get_sections(chn_full_media_type, :parameters)
)
gen_interaction = generated_quantities(
    interaction, MCMCChains.get_sections(chn_interaction, :parameters)
)
make_summary(gen_mediation, "Mediation $date"; type="mediation")
make_summary(gen_full, "Model $date"; type="full")
make_summary(gen_full_media_type, "Model Media Type $date"; type="full_media_type")
make_summary(gen_interaction, "Interaction $date"; type="interaction")

# saving table
CSV.write(joinpath(pwd(), "tables", "mediation_summary_$date.csv"))(
    make_df(gen_mediation; type="mediation")
)
CSV.write(joinpath(pwd(), "tables", "full_summary_$date.csv"))(
    make_df(gen_full; type="full")
)
CSV.write(joinpath(pwd(), "tables", "full_media_type_summary_$date.csv"))(
    make_df(gen_full_media_type; type="full_media_type")
)
CSV.write(joinpath(pwd(), "tables", "interaction_summary_$date.csv"))(
    make_df(gen_interaction; type="interaction")
)
