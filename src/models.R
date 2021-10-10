library(bayesplot)
library(cmdstanr)
library(here)
library(readr)

df <- read_csv(here("data", "responses_clean.csv"))

model <- cmdstan_model(here::here("stan", "m1.stan"))

dat <- list(
            N = nrow(df),
            be = df$be_mean,
            media = df$fsm,
            selfeff = df$selfeff_mean,
            fear = df$fear_mean,
            gender = df$sex_male,
            age = df$age
)

m1 <- model$sample(data = dat, parallel_chains = 4)
m1$summary()

posterior <- m1$draws()
ppc_dens_overlay(posterior)

ggsave(here("figures", "m1_dens.png"), dpi = 300)
