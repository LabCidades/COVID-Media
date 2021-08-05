include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

labels_list = [
    :fnp => "fnp - Newspaper",
    :ftv => "ftv - TV",
    :fra => "fra - Radio",
    :fws => "fws - Website",
    :fsm => "fsm - Social Media",
    :fmp => "fmp - Health Professionals",
    :fear_mean => "Fear",
    :risk_mean => "Perceived Risk",
    :selfeff_mean => "Self-Efficacy",
    :be_mean => "Protective  Behaviors"
]

figures_summaries = map(x -> draw_figure(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), "summary", quality=2), figures_summaries, labels_list)

figures_violin = map(x -> draw_violin(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), "violin", quality=2), figures_violin, labels_list)
