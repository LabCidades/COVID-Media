library(brms)
library(readr)
library(dplyr)
library(here)

df <- read_csv(here("data", "responses_clean.csv"))
df <- df %>% mutate(media_exposure = ftv + fnp + fsm)

y_model <- bf(be_sum ~ 1 + media_exposure + afra1)
m_model <- bf(afra1 ~ 1 + media_exposure)

model_mediation <- brm(
  y_model + m_model + set_rescor(FALSE),
  data = df,
  family = gaussian
)

# Summary Statistics
#                  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#                      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64

#                      α_fear    1.1148    0.0274     0.0003    0.0003    7334.2668    1.0004       19.3027
#      α_protective_behaviors   56.3064    0.3452     0.0039    0.0049    6595.8375    1.0005       17.3592
#                      σ_fear    1.0107    0.0084     0.0001    0.0001   10257.5963    1.0001       26.9964
#      σ_protective_behaviors   11.2305    0.0901     0.0010    0.0008    9726.3255    0.9998       25.5982
#     β_media_exposure_direct   -0.1256    0.0429     0.0005    0.0006    6869.7342    1.0006       18.0801
#   β_media_exposure_indirect    0.0739    0.0037     0.0000    0.0000    7477.1686    1.0002       19.6788
#                      β_fear    2.1226    0.1270     0.0014    0.0014    8224.3545    1.0001       21.6453

bayes_R2(model_mediation) %>% round(digits = 3)
