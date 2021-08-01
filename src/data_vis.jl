include(joinpath(pwd(), "src", "utils.jl"))

file = joinpath(pwd(), "data", "responses_clean.csv")
df = CSV.read(file, DataFrame)

labels_list = [
    :fnp => "Newspaper",
    :ftv => "TV",
    :fra => "Radio",
    :fws => "Website",
    :fsm => "Social Media",
    :fmp => "Health Professionals",
    :hb_b_pbe => "Healthy Behavior can Protect from COVID-19",
    :hb_a_pbe => "Healthy Behavior can Keep Health\n after Reading Information from Media?",
    :hb_b_se => "Confidence to Conduct Healthy Behaviours?",
    :hb_a_se => "Confidence to Conduct Healthy Behaviours During Outbreak?"
]

figures_summaries = map(x -> draw_figure(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), "summary", quality=2), figures_summaries, labels_list)

figures_violin = map(x -> draw_violin(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), "violin", quality=2), figures_violin, labels_list)
