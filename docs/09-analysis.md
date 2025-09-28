





# 様々な解析法{#chap09_Analysis}

この章では、t検定、χ二乗検定、分散分析、ノンパラメトリック検定など、心理学の基礎統計で学んだ手法について、Rでの解析方法を見ながらおさらいしていく。  
  
まず、この章で使うパッケージをロードする。


``` r
library(dplyr)
library(tidyr)
```


## t検定{#chap09_ttest}

「分析の対象が量的変数で、２つのグループの間でその変数の平均値を比較する」ときには、t検定を使う。更に、t検定には2つのグループに対応があるかないかで、「対応のあるt検定」と「対応のないt検定」で区別される。
  
前の章でもみてきたように、Rにはt検定を行うための`t.test()`関数が用意されている。


### 対応のないt検定{#chap09_indttest}

Rに標準で入っている`sleep`データを使って、Rでt検定をやってみよう。

以下のプログラムを読み込み、サンプルデータを作る。


``` r
sleep_1 = sleep |> dplyr::select(-ID)
sleep_1$ID = 1:nrow(sleep_1)
sleep_1
```

```
##    extra group ID
## 1    0.7     1  1
## 2   -1.6     1  2
## 3   -0.2     1  3
## 4   -1.2     1  4
## 5   -0.1     1  5
## 6    3.4     1  6
## 7    3.7     1  7
## 8    0.8     1  8
## 9    0.0     1  9
## 10   2.0     1 10
## 11   1.9     2 11
## 12   0.8     2 12
## 13   1.1     2 13
## 14   0.1     2 14
## 15  -0.1     2 15
## 16   4.4     2 16
## 17   5.5     2 17
## 18   1.6     2 18
## 19   4.6     2 19
## 20   3.4     2 20
```

IDは参加者を意味する番号で、1から20までの人がグループ1かグループ2のどれかに属し、変数`extra`を測定したとする。グループの間で`extra`に違いがあるかどうかを検討したい。

このように参加者が２つのグループのうちどれか一つに属しているケースが「対応のない場合」で、この場合は対応のないt検定で検討する。  
  
前の章で見たように、`t.test()`関数で以下のように入力すれば結果が出力される。


``` r
t.test(data = sleep_1, extra~group)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  extra by group
## t = -1.8608, df = 17.776, p-value = 0.07939
## alternative hypothesis: true difference in means between group 1 and group 2 is not equal to 0
## 95 percent confidence interval:
##  -3.3654832  0.2054832
## sample estimates:
## mean in group 1 mean in group 2 
##            0.75            2.33
```


### 対応のあるt検定{#chap09_pairedttest}

同じく、`sleep`データを使って対応のある場合について解析をしてみる。


``` r
sleep
```

```
##    extra group ID
## 1    0.7     1  1
## 2   -1.6     1  2
## 3   -0.2     1  3
## 4   -1.2     1  4
## 5   -0.1     1  5
## 6    3.4     1  6
## 7    3.7     1  7
## 8    0.8     1  8
## 9    0.0     1  9
## 10   2.0     1 10
## 11   1.9     2  1
## 12   0.8     2  2
## 13   1.1     2  3
## 14   0.1     2  4
## 15  -0.1     2  5
## 16   4.4     2  6
## 17   5.5     2  7
## 18   1.6     2  8
## 19   4.6     2  9
## 20   3.4     2 10
```

今度は10名の参加者が、グループ1とグループ2の両方に属して、それぞれで変数`extra`を測定したとする。

このように同じ参加者が２つのグループの両方に属しているケースが「対応のある場合」である。  
  
データを横並び（wide型）にしてから、`t.test()`関数で以下のようにプログラムを書けば、対応のあるt検定を実施できる。オプションに`paired = TRUE`を指定する。


``` r
sleep_2 = sleep |> tidyr::pivot_wider(names_from = group, values_from = extra) |> dplyr::rename(group_1 = `1`, group_2 = `2`)

head(sleep_2)  
```

```
## # A tibble: 6 × 3
##   ID    group_1 group_2
##   <fct>   <dbl>   <dbl>
## 1 1         0.7     1.9
## 2 2        -1.6     0.8
## 3 3        -0.2     1.1
## 4 4        -1.2     0.1
## 5 5        -0.1    -0.1
## 6 6         3.4     4.4
```

``` r
t.test(sleep_2$group_1, sleep_2$group_2, paired = TRUE)
```

```
## 
## 	Paired t-test
## 
## data:  sleep_2$group_1 and sleep_2$group_2
## t = -4.0621, df = 9, p-value = 0.002833
## alternative hypothesis: true mean difference is not equal to 0
## 95 percent confidence interval:
##  -2.4598858 -0.7001142
## sample estimates:
## mean difference 
##           -1.58
```


## 分散分析{#chap09_ANOVA}

t検定で比較できるのは2つのグループの間の平均値である。3グループ以上の間で平均値の比較を行いたい場合は、分散分析（ANOVA）を行う。  
  
ここでは、一要因３水準の分散分析（3つのグループの間で平均値を比較する）を例として、Rでの解析法について説明する。  
  
Rでは、一要因の分散分析をするための関数`aov()`が標準で入っている。同じくRで標準で入っている`PlantGrowth`データを使って解析をしてみよう。


``` r
anova_sample = PlantGrowth #PlantGrowthをanova_sampleという名前で保存する
anova_sample
```

```
##    weight group
## 1    4.17  ctrl
## 2    5.58  ctrl
## 3    5.18  ctrl
## 4    6.11  ctrl
## 5    4.50  ctrl
## 6    4.61  ctrl
## 7    5.17  ctrl
## 8    4.53  ctrl
## 9    5.33  ctrl
## 10   5.14  ctrl
## 11   4.81  trt1
## 12   4.17  trt1
## 13   4.41  trt1
## 14   3.59  trt1
## 15   5.87  trt1
## 16   3.83  trt1
## 17   6.03  trt1
## 18   4.89  trt1
## 19   4.32  trt1
## 20   4.69  trt1
## 21   6.31  trt2
## 22   5.12  trt2
## 23   5.54  trt2
## 24   5.50  trt2
## 25   5.37  trt2
## 26   5.29  trt2
## 27   4.92  trt2
## 28   6.15  trt2
## 29   5.80  trt2
## 30   5.26  trt2
```

植物の生長を3つの条件で調べたデータである。

まず、３つのグループごとに平均値や標準偏差を確認しよう。


``` r
anova_sample |> dplyr::group_by(group) |> 
  dplyr::summarise(Mean = mean(weight), SD = sd(weight), N = length(weight))
```

```
## # A tibble: 3 × 4
##   group  Mean    SD     N
##   <fct> <dbl> <dbl> <int>
## 1 ctrl   5.03 0.583    10
## 2 trt1   4.66 0.794    10
## 3 trt2   5.53 0.443    10
```

`ctrl`、`trt1`、`trt2`の間で平均値に差があるかを一要因の分散分析で検討する。以下のようにプログラムを書く。


``` r
result = aov(data = anova_sample, weight ~ group)
summary(result)
```

```
##             Df Sum Sq Mean Sq F value Pr(>F)  
## group        2  3.766  1.8832   4.846 0.0159 *
## Residuals   27 10.492  0.3886                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

`summary()`を使うと分散分析表が出力され、変数の効果が有意かを検討できる。  
  
または、一要因の分散分析ならば`oneway.test()`でも可能である。  
  

``` r
oneway.test(data = anova_sample, weight ~ group, var.equal = TRUE)#等分散の仮定のオプションを加える
```

```
## 
## 	One-way analysis of means
## 
## data:  weight and group
## F = 4.8461, num df = 2, denom df = 27, p-value = 0.01591
```


一要因の分散分析では「グループの間で平均値に差がない」という帰無仮説を検討する。この例については、p値は0.0159であり、5%水準で帰無仮説は棄却されることとなる。「グループの間で平均値に差がない」という可能性は棄却されたが、どのグループの間に有意な差があるかはわからない。そこで、グループ１とグループ２、グループ２とグループ３、グループ１とグループ３との間、計３つの組み合わせで平均値の比較を行う。つまり、t検定を3回行って条件間の比較をする。  
  
検定を繰り返すことは第１種の過誤を犯す確率を高めてしまう。そこで、検定を行う回数に応じてp値を厳し目に見積もることで、第１種の過誤を犯す確率を低くする工夫がなされる。この工夫が、「**多重比較補正**」と呼ばれるものである。

多重比較の補正を行うときは、`pairwise.t.test`関数を使う。各群間の比較について、補正後のp値が出力される。  
  
Rでは、多重比較補正を行うための関数として、`pairwise.t.test()`がある。


``` r
pairwise.t.test(anova_sample$weight, g = anova_sample$group, p.adjust.method = "bonferroni") #gにグループを意味する変数、p.adjust.methodに補正方法を指定する。
```

```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  anova_sample$weight and anova_sample$group 
## 
##      ctrl  trt1 
## trt1 0.583 -    
## trt2 0.263 0.013
## 
## P value adjustment method: bonferroni
```

グループの組み合わせごとに、補正後のp値が表示される。これを見ると、`trt1`と`trt2`との間で5%水準で有意な差があることがわかる。

多重比較補正には他にも、ボンフェローニ（Bonferroni)、チューキー(Tukey)、ホルム(Holm)の方法など様々な補正方法が提案されている。  チューキーによる補正の結果は、以下のプログラムで行う。 
  

``` r
result = aov(data = anova_sample, weight ~ group)
TukeyHSD(result) #分散分析の結果をTukeyHSDに入れる。
```

```
##   Tukey multiple comparisons of means
##     95% family-wise confidence level
## 
## Fit: aov(formula = weight ~ group, data = anova_sample)
## 
## $group
##             diff        lwr       upr     p adj
## trt1-ctrl -0.371 -1.0622161 0.3202161 0.3908711
## trt2-ctrl  0.494 -0.1972161 1.1852161 0.1979960
## trt2-trt1  0.865  0.1737839 1.5562161 0.0120064
```


***

分散分析は選択肢も多く、非常に複雑な解析方法である。二要因の分散分析、三要因の分散分析、更には二要因対応あり一要因対応なしの分散分析と、要因の数やそれぞれの要因の対応ありなしで分散分析のやり方も非常に複雑になる。  
更には、平方和の値の計算方法もタイプ1, タイプ2、タイプ3と様々な選択肢がある。  


## ノンパラメトリック検定{#chap09_nonpara}

以上のt検定や分散分析は、分析の対象の変数が「正規分布に従う」を前提とする解析手法である。変数が正規分布に従わない変数、例えば質的変数（人数の比率、順序尺度など）の場合には、t検定や分散分析を用いるのは適切でなく、「**ノンパラメトリック検定**」を使う。  
  
ノンパラメトリック検定とは「変数が正規分布に従うという前提を置かない解析手法」の総称であり、様々な種類が提案されている。  
  
以下では、ウィルコクソンの順位和検定、クラスカル・ウォリスの検定、カイ二乗検定について触れる。

### ウィルコクソンの順位和検定{#chap09_wilcox}

2群間で値を比較するノンパラメトリック検定である。データを順位データに変換し、2群間でデータの大きさを比較する。「マン・ホイットニーのU検定」という名前でも知られる。  
Rでは`wilcox.test()`が用意されている。


``` r
wilcox_sample = airquality |> filter(Month >= 8) #Rに入っているサンプルデータairqualityから2群だけ取り出したデータで試してみる
wilcox.test(data = wilcox_sample, Ozone ~ Month)
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  Ozone by Month
## W = 552, p-value = 0.003248
## alternative hypothesis: true location shift is not equal to 0
```

### クラスカル・ウォリスの検定{#chap09_kruskal}

3群以上で値を比較するノンパラメトリック検定である。同じく、データを順位データに変換して比較を行う。  
Rでは`kruskal.test()`が用意されている。


``` r
kruskal_sample = airquality #Rに入っているサンプルデータairqualityで試してみる
kruskal.test(data = kruskal_sample, Ozone ~ Month)
```

```
## 
## 	Kruskal-Wallis rank sum test
## 
## data:  Ozone by Month
## Kruskal-Wallis chi-squared = 29.267, df = 4, p-value = 6.901e-06
```

### カイ二乗検定{#chap09_chisq}

解析の対象の変数が質的変数で、頻度に偏りがあるかを比較したい場合は、カイ二乗検定が使われる。  
  
Rには、カイ二乗検定を行うための`chisq.test()`がある。


``` r
tab = matrix(c(12, 30, 25, 16), ncol=2) #表を作成する

chisq.test(tab) #chisq.testの中に表を入れる
```

```
## 
## 	Pearson's Chi-squared test with Yates' continuity correction
## 
## data:  tab
## X-squared = 7.5549, df = 1, p-value = 0.005985
```

カイ二乗検定は比率に偏りがあるかを検定してくれるが、どこに偏りがあるかは研究者自身が表を見て判断するしかない。  
  
## 「統計モデル」との関係{#chap09_summary}

この章では、心理統計で学んできた代表的な分析手法をRで行う方法について解説してきた。
一般的に心理統計では、「変数が正規分布に従い、グループが２つならばt検定」、「変数が正規分布に従い、グループが3つ以上ならば分散分析」、「変数がカテゴリカル変数ならばカイ二乗検定」といったように、変数のタイプや研究デザインに応じて行う解析を選ぶ方法が提案されている。  
  
しかし、上に挙げた条件に当てはまらないデータの場合は、どのような分析をすれば良いのだろうか？   
    
以降の章では、これまで学んできた分析手法を統計モデルという一つの枠組みで捉え直していく。
