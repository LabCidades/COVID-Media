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
    :hb_p_pbe => "Healthy Behavior can Protect from COVID-19",
    :hb_a_pbe => "Healthy Behavior can Keep Health\n after Reading Information from Media?",
    :hb_b_se => "Confidence to Conduct Healthy Behaviours?",
    :hb_a_se => "Confidence to Conduct Healthy Behaviours During Outbreak?"
]

figures = map(x -> draw_figure(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), quality=2), figures, labels_list)
