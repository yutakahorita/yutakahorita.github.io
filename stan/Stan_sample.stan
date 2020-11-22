data{
  int N;
  real x_1[N];
  real x_2[N];
}

parameters{
  real mu_1;
  real mu_2;
  real<lower = 0> sigma_1;
  real<lower = 0> sigma_2;
}

model{
  mu_1 ~ normal(0,100);
  mu_2 ~ normal(0,100);
  for(n in 1:N){
    x_1 ~ normal(mu_1, sigma_1);
    x_2 ~ normal(mu_2, sigma_2);
  }
}

