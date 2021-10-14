using AlgebraOfGraphics
using CairoMakie
using ColorTypes
using CSV
using DataFrames

# Clean Data
# Categorical Coding
function recode_hb(x::AbstractString)
    return x == "Discordo fortemente"       ? -2 :
           x == "Discordo"                  ? -1 :
           x == "Não concordo nem discordo" ? 0  :
           x == "Concordo"                  ? 1  :
           x == "Concordo fortemente"       ? 2  : missing
end

function recode_hb_inverse(x::Int)
    return x == -2 ? 2  :
           x == -1 ? 1  :
           x == 0  ? 0  :
           x == 1  ? -1 :
           x == 2  ? -2 : missing
end

function recode_afra(x::AbstractString)
    return x == "Não estou com medo"   ? 0 :
           x == "Um pouco amedrontado" ? 1 :
           x == "Amedrontado"          ? 2 :
           x == "Bastante amedrontado" ? 3 : missing
end

function recode_be(x::AbstractString)
    return x == "Nunca"          ? 0 :
           x == "Pouco"          ? 1 :
           x == "Algumas vezes"  ? 2 :
           x == "Frequentemente" ? 3 :
           x == "Sempre"         ? 4 : missing
end

function recode_fmedia(x::AbstractString)
    return x == "Nunca"          ? 0 :
           x == "Raramente"      ? 1 :
           x == "Algumas vezes"  ? 2 :
           x == "Frequentemente" ? 3 :
           x == "Sempre"         ? 4 : missing
end

function recode_confi(x::AbstractString)
    return x == "Totalmente discrente"   ? 0 :
           x == "Com um pouco de dúvida" ? 1 :
           x == "Confiante"              ? 2 :
           x == "Muito confiante"        ? 3 : missing
end

function recode_age(x::AbstractString)
    return x == "Abaixo de 17 anos" ? 1 :
           x == "18-30 anos"        ? 2 :
           x == "31-50 anos"        ? 3 :
           x == "51-70 anos"        ? 4 :
           x == "Acima de 70 anos"  ? 5 : missing
end

function recode_mariage(x::AbstractString)
    return x == "Solteiro(a)"                  ? 1 :
           x == "Casado(a) ou União Estável"   ? 2 :
           x == "Divorciado(a) ou Separado(a)" ? 3 :
           x == "Viúvo(a)"                     ? 3 : missing
end

function recode_income(x::AbstractString)
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
            names(df, r"^confi_")  .=> x -> recode_confi.(x);
            renamecols=false)
    # Negative Coded Variables
    transform!(df,
               :hb_a_pba            => x -> recode_hb_inverse.(x);
               renamecols=false)

    transform!(df,
            names(df, r"^afra")     => ByRow(+) => :fear_sum,
            names(df, r"^be_")      => ByRow(+) => :be_sum,
            [:hb_b_psu, :hb_b_pse,
             :hb_a_psu, :hb_a_pse]  => ByRow(+) => :risk_sum,
            [:hb_b_se, :hb_b_pse,
             :hb_b_pbe, :hb_a_pba,
             :hb_a_se]              => ByRow(+) => :selfeff_sum)
    transform!(df,
            :fear_sum               => ByRow(x -> x / length(names(df, r"^afra"))) => :fear_mean,
            :be_sum                 => ByRow(x -> x / length(names(df, r"^be_")))  => :be_mean,
            :risk_sum               => ByRow(x -> x / 4)  => :risk_mean,
            :selfeff_sum            => ByRow(x -> x / 5)  => :selfeff_mean)
end

# Data Vis
function draw_violin(df::DataFrame, label::Pair{Symbol, String})
    # Problems with Int stuff
    transform(df, label.first => float, renamecols=false)

    # Create Figure
    resolution = (800, 640)
    fig = Figure(; resolution)

    # Create Specs
    specs_data = data(df)
    specs_density = specs_data * mapping(
                label.first => "";
                color=:sex_male => renamer(0 => "Female", 1 => "Male") => "Sex") *
                histogram(normalization=:pdf) * visual(alpha=0.5)
    specs_violin = specs_data * mapping(
                :age => renamer(1 => "17-", 2 => "18-30", 3 => "31-50", 4 => "51-70", 5 => "70+"),
                label.first => "";
                color=:sex_male => renamer(0 => "Female", 1 => "Male") => "",
                side=:sex_male => renamer(0 => "Female", 1 => "Male")  => "") *
                visual(Violin, show_median=true, medianlinewidth=3)



    # Draw Figure
    draw!(fig[1, 1], specs_density; axis=(title=label.second, titlesize=24, titlecolor=(:black, 1.0)))
    draw!(fig[2, 1], specs_violin)

    # Custom Legend
    # Blue Female
    # Orange Male
    elem_1 = PolyElement(color=RGBAf0(0.0f0,0.44705883f0,0.69803923f0,1.0f0))
    elem_2 = PolyElement(color=RGBAf0(0.9019608f0,0.62352943f0,0.0f0,1.0f0))
    fig[end+1, 1] = Legend(fig,[elem_1, elem_2], ["Female", "Male"];
                           tellwidth=false, tellheight=true, orientation=:horizontal)
    return fig
end

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
    draw!(fig[3, 1], specs_sex; axis=(; xticklabelrotation=0.5))
    draw!(fig[3, 2], specs_age; axis=(; xticklabelrotation=0.5))
    draw!(fig[4, 1], specs_marriage; axis=(; xticklabelrotation=0.5))
    draw!(fig[4, 2], specs_income; axis=(; xticklabelrotation=0.5))

    # Supertitle
    fig[0, 1:2] = Label(fig, label.second, textsize=36, color=(:black, 1.0))

    # Legend
    # fig[end+1, 1:] = Legend(fig, [specs_boxplot, specs_boxplot], ["Female", "Male"])
    return fig
end

function save_figure(fig::Figure, filename::String, prefix::String; quality=3)
    save(joinpath(pwd(), "figures", "$(prefix)_$(filename).png"), fig, px_per_unit=quality)
end
