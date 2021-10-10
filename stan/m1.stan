data {
  int<lower=0> N;
  vector[N] be;
  vector[N] media;
  vector[N] selfeff;
  vector[N] fear;
  vector[N] gender;
  vector[N] age;
}
transformed data {
  // standard scaling
  // mu = 0 std = 1
  vector[N] be_std = (be - mean(be)) / sd(be);
  vector[N] media_std = (media - mean(media)) / sd(media);
  vector[N] selfeff_std = (selfeff - mean(selfeff)) / sd(selfeff);
  vector[N] fear_std = (fear - mean(fear)) / sd(fear);
  vector[N] gender_std = (gender - mean(gender)) / sd(gender);
  vector[N] age_std = (age - mean(age)) / sd(age);
}
parameters {
  real alpha;
  real beta_media_be;
  real beta_selfeff_be;
  real beta_fear_be;
  real beta_gender_media;
  real beta_age_media;
  real beta_gender_fear;
  real beta_age_fear;
  real sigma;
}
model {
  // priors
  beta_media_be ~ student_t(3, 0, 1);
  beta_selfeff_be ~ student_t(3, 0, 1);
  beta_fear_be ~ student_t(3, 0, 1);
  beta_gender_media ~ student_t(3, 0, 1);
  beta_age_media ~ student_t(3, 0, 1);
  beta_gender_fear ~ student_t(3, 0, 1);
  beta_age_fear ~ student_t(3, 0, 1);
  sigma ~ exponential(1);
  // effects
  vector[N] media_var = (gender_std * beta_gender_media) +
              (age_std * beta_age_media);
  vector[N] fear_var = (gender_std * beta_gender_fear) +
              (age_std * beta_age_fear);
  // linear predictor
  vector[N] mu = alpha +
        (media_var * beta_media_be) +
        (selfeff_std * beta_selfeff_be) +
        (fear_var * beta_fear_be);
  // likelihood
  be ~ normal(mu, sigma);
}
generated quantities {
  // derive quantities in raw scaling
}
