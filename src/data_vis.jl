using AlgebraOfGraphics
using CairoMakie
using CategoricalArrays
using CSV
using DataFrames

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

figures = map(x -> draw_figure(df, x), labels_list)
map((x, y) -> save_figure(x, string(y.first), quality=2), figures, labels_list)
