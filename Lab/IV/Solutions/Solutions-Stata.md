
# Fulton Fish Market Replication

First, we will load data from Graddy (1995) who observes daily fish
prices and quantities from the Fulton Fish Market in NYC. ![Fulton Fish
Market in
NYC](https://upload.wikimedia.org/wikipedia/commons/9/97/Fultonfishmarket.jpg)

The goal of this paper is to estimate the demand elasticity of fish
prices $$
Q = \alpha + \delta P + \gamma X + \varepsilon
$$ Since price and quantity are simultaneous equations, we need an
instrument that shocks $P$. Graddy (1995) uses the two-day lagged
weather which determines that day’s market price for fish.

Load the Fulton Fish Market data from
`https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta`

``` stata
use "https://github.com/Mixtape-Sessions/Causal-Inference-1/raw/main/Lab/IV/Fulton.dta", clear
```

    end of do-file

1.  Run OLS of `q` on `p` controlling for indicators for day of the week
    (`Mon`, `Tue`, `Wed`, `Thu`).

``` stata
reg q p i.Mon i.Tue i.Wed i.Thu, r
```

    Linear regression                               Number of obs     =        111
                                                    F(5, 105)         =       9.40
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.2205
                                                    Root MSE          =     .67023

    ------------------------------------------------------------------------------
                 |               Robust
               q |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
               p |  -.5625496   .1521747    -3.70   0.000     -.864284   -.2608153
           1.Mon |   .0143165   .2057287     0.07   0.945    -.3936055    .4222384
           1.Tue |  -.5162417   .1897271    -2.72   0.008    -.8924354    -.140048
           1.Wed |  -.5553729   .1937012    -2.87   0.005    -.9394466   -.1712992
           1.Thu |   .0816213   .1620358     0.50   0.616    -.2396658    .4029084
           _cons |   8.606893   .1183165    72.74   0.000     8.372293    8.841493
    ------------------------------------------------------------------------------

2.  Instrument for `p` using the variable `Stormy` which is an indicator
    for it being stormy in the past two days.

``` stata
ivreg2 q i.Mon i.Tue i.Wed i.Thu (p = Stormy), r
```

    IV (2SLS) estimation
    --------------------

    Estimates efficient for homoskedasticity only
    Statistics robust to heteroskedasticity

                                                          Number of obs =      111
                                                          F(  5,   105) =     4.72
                                                          Prob > F      =   0.0006
    Total (centered) SS     =  60.50851701                Centered R2   =   0.1391
    Total (uncentered) SS   =  8124.531197                Uncentered R2 =   0.9936
    Residual SS             =  52.09032078                Root MSE      =     .685

    ------------------------------------------------------------------------------
                 |               Robust
               q |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
               p |  -1.119417   .4310487    -2.60   0.009    -1.964257   -.2745771
           1.Mon |  -.0254022   .2153699    -0.12   0.906    -.4475195    .3967151
           1.Tue |  -.5307694   .1965537    -2.70   0.007    -.9160076   -.1455311
           1.Wed |  -.5663511   .2012562    -2.81   0.005     -.960806   -.1718962
           1.Thu |   .1092673   .1735489     0.63   0.529    -.2308824     .449417
           _cons |   8.505911   .1479025    57.51   0.000     8.216028    8.795795
    ------------------------------------------------------------------------------
    Underidentification test (Kleibergen-Paap rk LM statistic):             16.925
                                                       Chi-sq(1) P-val =    0.0000
    ------------------------------------------------------------------------------
    Weak identification test (Cragg-Donald Wald F statistic):               21.517
                             (Kleibergen-Paap rk Wald F statistic):         22.929
    Stock-Yogo weak ID test critical values: 10% maximal IV size             16.38
                                             15% maximal IV size              8.96
                                             20% maximal IV size              6.66
                                             25% maximal IV size              5.53
    Source: Stock-Yogo (2005).  Reproduced by permission.
    NB: Critical values are for Cragg-Donald F statistic and i.i.d. errors.
    ------------------------------------------------------------------------------
    Hansen J statistic (overidentification test of all instruments):         0.000
                                                     (equation exactly identified)
    ------------------------------------------------------------------------------
    Instrumented:         p
    Included instruments: 1.Mon 1.Tue 1.Wed 1.Thu
    Excluded instruments: Stormy
    ------------------------------------------------------------------------------

3.  Argue for or against the validity of the instrument.

*Comment:* In the classical supply and demand IV setting, you want you
instrument to affect *either* supply *or* demand, but not both. In this
setting, it would be necessary (and potentially plausible) that stormy
weather affects the suppliers only since the restaurants and people of
New York demand isn’t affected by the weather.

However, here are two potential reasons this shock affects demand as
well. First, the stormy weather could change the composition of fish
caught. In this case, you’d violate the exclusion restriction since
demand would be changing. Second, the weather could affect consumers
decisions if for example, they eat out more in the days following a
storm.

# Card Replication

Next, we will turn to the classical IV example of Card (1995). Card aims
to estimate the returns to college education, but is worried about
omitted variable bias when regressing wages on years of education. In
this case, the coefficient on education is likely biased upwards by
unobserved ability since it is plausibly positively correlated with
education and with wages.

Load the Card data from
`https://raw.github.com/scunning1975/mixtape/master/card.dta`

``` stata
use "https://raw.github.com/scunning1975/mixtape/master/card.dta", clear
```

1.  Regress the log wage `lwage` on years of education `educ`
    controlling for experience (`exper`), an indicator for being Black
    (`black`), an indicator for being in the South (`south`), an
    indicator for being married (`married`), and an indicator for living
    in an urban area (`smsa`).

``` stata
reg lwage educ exper i.black i.south i.married i.smsa, r
```

    Linear regression                               Number of obs     =      3,003
                                                    F(10, 2992)       =     144.92
                                                    Prob > F          =     0.0000
                                                    R-squared         =     0.3069
                                                    Root MSE          =     .36998

    ------------------------------------------------------------------------------
                 |               Robust
           lwage |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
            educ |    .071006   .0036143    19.65   0.000     .0639191    .0780928
           exper |   .0336501   .0022757    14.79   0.000     .0291881    .0381122
         1.black |  -.1670214    .017491    -9.55   0.000    -.2013169   -.1327258
         1.south |  -.1324423    .015203    -8.71   0.000    -.1622517    -.102633
                 |
         married |
              2  |  -.0320507   .0714327    -0.45   0.654    -.1721129    .1080114
              3  |  -.4419197   .0561156    -7.88   0.000    -.5519488   -.3318905
              4  |  -.0599139   .0346484    -1.73   0.084    -.1278509    .0080231
              5  |  -.0902941   .0372571    -2.42   0.015    -.1633461    -.017242
              6  |  -.1925839   .0190838   -10.09   0.000    -.2300027   -.1551651
                 |
          1.smsa |   .1747579    .015102    11.57   0.000     .1451466    .2043692
           _cons |   5.034089   .0655482    76.80   0.000     4.905565    5.162613
    ------------------------------------------------------------------------------

2.  Using the same set of controls, run an instrumental variables
    regression instrumenting `educ` by `nearc4` which is an indicator
    for being near a 4-year college/university.

``` stata
ivreg2 lwage exper i.black i.south i.married i.smsa (educ = i.nearc4), r
```

    IV (2SLS) estimation
    --------------------

    Estimates efficient for homoskedasticity only
    Statistics robust to heteroskedasticity

                                                          Number of obs =     3003
                                                          F( 10,  2992) =    99.00
                                                          Prob > F      =   0.0000
    Total (centered) SS     =  590.9611167                Centered R2   =   0.2565
    Total (uncentered) SS   =  118352.1588                Uncentered R2 =   0.9963
    Residual SS             =  439.3808865                Root MSE      =    .3825

    ------------------------------------------------------------------------------
                 |               Robust
           lwage |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
            educ |   .1224377   .0482967     2.54   0.011      .027778    .2170975
           exper |   .0545088   .0195642     2.79   0.005     .0161637    .0928539
         1.black |  -.1190648   .0481265    -2.47   0.013    -.2133911   -.0247385
         1.south |  -.1144891   .0227841    -5.02   0.000     -.159145   -.0698331
                 |
         married |
              2  |   .0394414   .1005979     0.39   0.695    -.1577269    .2366096
              3  |  -.4520338   .0441475   -10.24   0.000    -.5385612   -.3655063
              4  |   -.060073   .0358315    -1.68   0.094    -.1303014    .0101554
              5  |  -.0786235    .040102    -1.96   0.050     -.157222    -.000025
              6  |  -.1714813   .0273527    -6.27   0.000    -.2250916    -.117871
                 |
          1.smsa |   .1479248    .029555     5.01   0.000     .0899981    .2058515
           _cons |   4.162923   .8172968     5.09   0.000     2.561051    5.764795
    ------------------------------------------------------------------------------
    Underidentification test (Kleibergen-Paap rk LM statistic):             16.816
                                                       Chi-sq(1) P-val =    0.0000
    ------------------------------------------------------------------------------
    Weak identification test (Cragg-Donald Wald F statistic):               16.246
                             (Kleibergen-Paap rk Wald F statistic):         16.964
    Stock-Yogo weak ID test critical values: 10% maximal IV size             16.38
                                             15% maximal IV size              8.96
                                             20% maximal IV size              6.66
                                             25% maximal IV size              5.53
    Source: Stock-Yogo (2005).  Reproduced by permission.
    NB: Critical values are for Cragg-Donald F statistic and i.i.d. errors.
    ------------------------------------------------------------------------------
    Hansen J statistic (overidentification test of all instruments):         0.000
                                                     (equation exactly identified)
    ------------------------------------------------------------------------------
    Instrumented:         educ
    Included instruments: exper 1.black 1.south 2.married 3.married 4.married
                          5.married 6.married 1.smsa
    Excluded instruments: 1.nearc4
    ------------------------------------------------------------------------------

3.  Compare the two results, does the IV estimate move in the direction
    we predicted above? Use the concept of LATE to describe why the
    coefficient moved in the direction it did.

*Comment:*

In the above description, if ability is correlated with years of
education, then the OLS regression coefficient for years of education
will be biased upward since it picks up on the effect of ability
(omitted variables bias). However, the IV regression coefficient
actually *increased* which is not what we would expect.

The answer that Card gives is that perhaps the individuals who are
*induced* into entering college by the instrument (being close to
college) benefit more from college than the general population. In this
case the LATE \> ATE which is why the coefficient grows larger.

Though, not covered in the course, it is possible to describe the
compliers (see [Peter Hull’s
Slides](https://github.com/Mixtape-Sessions/Instrumental-Variables/raw/main/Slides/03-HeterogeneousFX.pdf)).
For example, we can see that the compliers tend to have a larger
proportion of single mothers. These individuals might benefit more from
attending college than the general population, i.e. the LATE \> ATE

``` stata
gen sinmom14_x_enroll = sinmom14 * enroll
ivreg2 sinmom14_x_enroll exper i.black i.south i.married i.smsa (enroll = i.nearc4)
```

    IV (2SLS) estimation
    --------------------

    Estimates efficient for homoskedasticity only
    Statistics consistent for homoskedasticity only

                                                          Number of obs =     3003
                                                          F( 10,  2992) =     1.50
                                                          Prob > F      =   0.1319
    Total (centered) SS     =  17.89210789                Centered R2   =  -0.4549
    Total (uncentered) SS   =           18                Uncentered R2 =  -0.4461
    Residual SS             =  26.03042563                Root MSE      =    .0931

    ------------------------------------------------------------------------------
    sinmom14_x~l |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
          enroll |   .2612554    .235229     1.11   0.267    -.1997848    .7222957
           exper |   .0020314   .0025639     0.79   0.428    -.0029938    .0070565
         1.black |   .0112037   .0043855     2.55   0.011     .0026082    .0197992
         1.south |  -.0021887   .0047855    -0.46   0.647    -.0115682    .0071908
                 |
         married |
              2  |   .0045824   .0292596     0.16   0.876    -.0527654    .0619302
              3  |   .0120022   .0568299     0.21   0.833    -.0993824    .1233868
              4  |   .0065511   .0078493     0.83   0.404    -.0088333    .0219355
              5  |  -.0003414    .013244    -0.03   0.979    -.0262992    .0256164
              6  |  -.0127554   .0050186    -2.54   0.011    -.0225917   -.0029191
                 |
          1.smsa |   -.009916   .0088144    -1.12   0.261     -.027192    .0073599
           _cons |  -.0287101   .0378408    -0.76   0.448    -.1028767    .0454566
    ------------------------------------------------------------------------------
    Underidentification test (Anderson canon. corr. LM statistic):           1.924
                                                       Chi-sq(1) P-val =    0.1655
    ------------------------------------------------------------------------------
    Weak identification test (Cragg-Donald Wald F statistic):                1.918
    Stock-Yogo weak ID test critical values: 10% maximal IV size             16.38
                                             15% maximal IV size              8.96
                                             20% maximal IV size              6.66
                                             25% maximal IV size              5.53
    Source: Stock-Yogo (2005).  Reproduced by permission.
    ------------------------------------------------------------------------------
    Sargan statistic (overidentification test of all instruments):           0.000
                                                     (equation exactly identified)
    ------------------------------------------------------------------------------
    Instrumented:         enroll
    Included instruments: exper 1.black 1.south 2.married 3.married 4.married
                          5.married 6.married 1.smsa
    Excluded instruments: 1.nearc4
    ------------------------------------------------------------------------------
