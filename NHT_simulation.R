library(tidyverse)

#t検定のシミュレーション
#同じ母集団から標本を抽出して２グループ間でt検定を行う
set.seed(1234)
result = data.frame()
for(s in 1:100){
  s_1 = rnorm(n = 100, mean = 0, sd = 1)
  s_2 = rnorm(n = 100, mean = 0, sd = 1)
  d = data.frame(group = c(rep(1,100), rep(2, 100)), value = c(s_1, s_2))
  ttest = t.test(data = d, value ~ group)
  p = ttest$p.value
  
  temp = data.frame(s = s, p = p)
    result = rbind(result, temp)
}

result$significant = ifelse(result$p < 0.05, 1, 0)
table(result$significant)

ggplot() + 
  geom_point(data = result, aes(x = s, y = p)) + 
  geom_hline(yintercept = 0.05, color = "red") +
  labs(x = "simulation", y = "p value")


#t検定のシミュレーション
#|mu_{1} - mu_{2}| = 1の集団間でサンプル数を変えてt検定を実施
set.seed(1)
result = data.frame()
for(n in 2:100){
  for(s in 1:1000){
    s_1 = rnorm(n = n, mean = 0, sd = 1)
    s_2 = rnorm(n = n, mean = 1, sd = 1)
    d = data.frame(group = c(rep(1,n), rep(2, n)), value = c(s_1, s_2))
    ttest = t.test(data = d, value ~ group)
    p = ttest$p.value
  
    temp = data.frame(n = n, s = s, p = p)
    result = rbind(result, temp)
  }
}

## mu_1 = mu_2の条件でサンプル数を少しずつ増やす
set.seed(1234)
result = data.frame()
#s = 1
#for(s in 1:10){
  n = 10
  while(n <= 100){
    s_1 = rnorm(n = n, mean = 0, sd = 1)
    s_2 = rnorm(n = n, mean = 0, sd = 1)
    d = data.frame(group = c(rep(1, n), rep(2, n)), value = c(s_1, s_2))
    ttest = t.test(data = d, value ~ group)
    p = ttest$p.value
  
    temp = data.frame(n = n, s = s, p = p)
    result = rbind(result, temp)
    n = n + 1
  }
#}
result$significant = ifelse(result$p < 0.05, 1, 0)
table(result$significant)


ggplot() + 
  geom_line(data = result, aes(x = n, y = p)) + 
  geom_hline(yintercept = 0.05, color = "red") +
  scale_x_continuous(breaks = seq(10,100,5)) + 
  labs(x = "N", y = "p value")

