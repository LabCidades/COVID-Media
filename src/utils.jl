using AlgebraOfGraphics
using CairoMakie
using CSV
using DataFrames
using LinearAlgebra: Diagonal
using Statistics: cov

# Clean Data
# Categorical Coding
function recode_hb(x::String)
    return x == "Discordo fortemente"       ? -2 :
           x == "Discordo"                  ? -1 :
           x == "Não concordo nem discordo" ? 0  :
           x == "Concordo"                  ? 1  :
           x == "Concordo fortemente"       ? 2  : missing
end

function recode_afra(x::String)
    return x == "Não estou com medo"   ? 0 :
           x == "Um pouco amedrontado" ? 1 :
           x == "Amedrontado"          ? 2 :
           x == "Bastante amedrontado" ? 3 : missing
end

function recode_be(x::String)
    return x == "Nunca"          ? 0 :
           x == "Pouco"          ? 1 :
           x == "Algumas vezes"  ? 2 :
           x == "Frequentemente" ? 3 :
           x == "Sempre"         ? 4 : missing
end

function recode_fmedia(x::String)
    return x == "Nunca"          ? 0 :
           x == "Raramente"      ? 1 :
           x == "Algumas vezes"  ? 2 :
           x == "Frequentemente" ? 3 :
           x == "Sempre"         ? 4 : missing
end

function recode_confi(x::String)
    return x == "Totalmente discrente"   ? 0 :
           x == "Com um pouco de dúvida" ? 1 :
           x == "Confiante"              ? 2 :
           x == "Muito confiante"        ? 3 : missing
end

function recode_age(x::String)
    return x == "Abaixo de 17 anos" ? 1 :
           x == "18-30 anos"        ? 2 :
           x == "31-50 anos"        ? 3 :
           x == "51-70 anos"        ? 4 :
           x == "Acima de 70 anos"  ? 5 : missing
end

function recode_mariage(x::String)
    return x == "Solteiro(a)"                  ? 1 :
           x == "Casado(a) ou União Estável"   ? 2 :
           x == "Divorciado(a) ou Separado(a)" ? 3 :
           x == "Viúvo(a)"                     ? 3 : missing
end

function recode_income(x::String)
    return x == "Até R\$ 178"              ? 1 :
           x == "De R\$ 179 a R\$ 368"     ? 2 :
           x == "De R\$ 369 a R\$ 1.008"   ? 3 :
           x == "De R\$ 1.009 a R\$ 3.566" ? 4 :
           x == "Acima de R\$ 3.566"       ? 5 : missing
end

function clean_data!(df::DataFrame)
    # Drop Missing Values
    dropmissing!(df, [:age, :sex, :marriage, :income])
    dropmissing!(df, r"^hb_")
    dropmissing!(df, r"^afra")
    dropmissing!(df, r"^be_")
    dropmissing!(df, r"^f\w{2}")
    dropmissing!(df, r"^confi_")
    filter!(:sex => !=("Prefiro não dizer"), df)

    # Transformations
    transform!(df, :sex => ByRow(x -> ifelse(x == "Masculino", 1, 0)) => :sex_male)

    select!(df,
            :age                    => x -> recode_age.(x),
            :sex_male,
            :marriage               => x -> recode_mariage.(x),
            :income                 => x -> recode_income.(x),
            names(df, r"^hb_")     .=> x -> recode_hb.(x),
            names(df, r"^afra")    .=> x -> recode_afra.(x),
            names(df, r"^be_")     .=> x -> recode_be.(x),
            names(df, r"^f\w{2}")  .=> x -> recode_fmedia.(x),
            names(df, r"^confi_")  .=> x -> recode_confi.(x),
            renamecols=false)
    transform!(df,
            names(df, r"^hb_")     => ByRow(+) => :hb_sum,
            names(df, r"^afra")    => ByRow(+) => :afra_sum,
            names(df, r"^be_")     => ByRow(+) => :be_sum)
end

# Crombach

"""
Calculate Crombach's Alpha (1951) according to the Wikipedia formula:
https://en.wikipedia.org/wiki/Cronbach%27s_alpha
"""
function crombach(covmatrix::AbstractMatrix{T}) where T <: Real
    k = size(covmatrix, 2)
    σ = sum(covmatrix)
    σ_ij = sum(covmatrix - Diagonal(covmatrix)) / (k * (k - 1))
    ρ = k^2 * σ_ij / σ
    return ρ
end

# Data Vis

# function draw_figures(df::DataFrame, x::Symbol, label::String, grouping::Symbol)
#     # Create Figure
#     resolution = (800, 640) .* 1.5
#     fig = Figure(; resolution)

#     # Create Specs
#     specs_data = data(df)
#     specs_histogram = specs_data * mapping(x => "") * frequency()
#     specs_boxplot = data(df) * mapping(
#                 :age => renamer(1 => "17-", 2 => "18-30", 3 => "31-50", 4 => "51-70", 5 => "70+"),
#                 x => "",
#                 color=:sex_male => renamer(0 => "Female", 1 => "Male"),
#                 dodge=:sex_male => renamer(0 => "Female", 1 => "Male")) *
#                 visual(BoxPlot)

#     if grouping == :marriage
#         specs_boxplot *= mapping(col=:marriage => renamer(1 => "Single",
#                                                           2 => "Married",
#                                                           3 => "Divorced/Widow"))


#         # Draw Figure
#         draw!(fig[1, 1:6], specs_histogram; axis=(label, aspect=2.5,))
#         draw!(fig[2, 1:6], specs_boxplot; axis=(xticklabelrotation=0.5,))

#         # Supertitle
#         fig[0, 1:6] = Label(fig, label, textsize=24, color=(:black, 1.0))

#         # Legend
#         # fig[end+1, 1:] = Legend(fig, [specs_boxplot, specs_boxplot], ["Female", "Male"])
#         return fig

#     elseif grouping == :income
#         specs_boxplot *= mapping(layout=:income => renamer(1 => "BRL 0 - 178",
#                                                            2 => "BRL 179 - 368",
#                                                            3 => "BRL 369 - 1,008",
#                                                            4 => "BRL 1,009 - 3,566",
#                                                            5 => "BRL 3,557+"))

#         # Draw Figure
#         draw!(fig[1, 1:3], specs_histogram; axis=(aspect=2.5,))
#         draw!(fig[2:3,1:3], specs_boxplot; axis=(xticklabelrotation=0.5,))

#         # Supertitle
#         fig[0, 1:3] = Label(fig, label, textsize=24, color= (:black, 1.0))
#         return fig
#     end
# end

function draw_figure(df::DataFrame, label::Pair{Symbol, String})
    # Problems with Int stuff
    transform!(df, label.first => float, renamecols=false)
    transform!(df, [:sex_male, :age, :marriage, :income] .=> float, renamecols=false)

    # Create Figure
    resolution = (800, 640) .* 1.5
    fig = Figure(; resolution)

    # Create Specs
    specs_data = data(df)
    specs_histogram = specs_data * mapping(label.first => "Frequency") * frequency()
    specs_sex = specs_data * mapping(:sex_male => renamer(0 => "Female", 1 => "Male") => "sex",
                                     label.first => "") *
                                expectation()
    specs_age = specs_data * mapping(:age => renamer(
                                        1 => "17-",
                                        2 => "18-30",
                                        3 => "31-50",
                                        4 => "51-70",
                                        5 => "70+"),
                                     label.first => "") *
                                expectation()
    specs_marriage = specs_data * mapping(:marriage => renamer(
                                            1 => "Single",
                                            2 => "Married",
                                            3 => "Divorced/Widow"),
                                          label.first => "") *
                                     expectation()

    specs_income = specs_data * mapping(:income => renamer(
                                           1 => "BRL 0 - 178",
                                           2 => "BRL 179 - 368",
                                           3 => "BRL 369 - 1,008",
                                           4 => "BRL 1,009 - 3,566",
                                           5 => "BRL 3,557+"),
                                        label.first => "") *
                                   expectation()

    # Draw Figure
    draw!(fig[1, 1:2], specs_histogram)
    fig[2, 1:2] = Label(fig, "Expectation", textsize=24, color=(:black, 1.0))
    draw!(fig[3, 1], specs_sex; axis=(xticklabelrotation=0.5,))
    draw!(fig[3, 2], specs_age; axis=(xticklabelrotation=0.5,))
    draw!(fig[4, 1], specs_marriage; axis=(xticklabelrotation=0.5,))
    draw!(fig[4, 2], specs_income; axis=(xticklabelrotation=0.5,))

    # Supertitle
    fig[0, 1:2] = Label(fig, label.second, textsize=36, color=(:black, 1.0))

    # Legend
    # fig[end+1, 1:] = Legend(fig, [specs_boxplot, specs_boxplot], ["Female", "Male"])
    return fig
end

function save_figure(fig::Figure, filename::String; quality=3)
    save(joinpath(pwd(), "figures", "$(filename).png"), fig, px_per_unit=quality)
end
