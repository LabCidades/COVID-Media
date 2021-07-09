using CSV
using DataFrames

file = joinpath(pwd(), "data", "responses_raw.csv")
df = CSV.read(file, DataFrame)

# Drop Missing Values
dropmissing!(df, [:age, :sex, :marriage, :income])
dropmissing!(df, r"^hb_")
filter!(:sex => !=("Prefiro não dizer"), df)

# Categorical Coding
# transform!(df, [:age, :sex, :marriage, :income] .=> categorical, renamecols=false)

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
           x == "Pouco"      ? 1 :
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

df |> CSV.write(joinpath(pwd(), "data", "responses_clean.csv"))
