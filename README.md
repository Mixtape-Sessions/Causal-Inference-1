<img src="https://raw.githubusercontent.com/Mixtape-Sessions/Causal-Inference-1/main/img/banner.png" alt="Mixtape Sessions Banner" width="100%"> 


## About

Causal Inference Part I kickstarts a new 4-day series on design-based causal inference series. It covers the foundations of causal inference grounded in a counterfactual theory of causality built on the Neyman-Rubin model of potential outcomes. It will also cover randomization inference, independence, matching, regression discontinuity and instrumental variables. We will review the theory behind each of these designs in detail with the aim being comprehension, competency and confidence. Each day is 8 hours with 15 minute breaks on the hour plus an hour for lunch. To help accomplish this, we will hold ongoing discussions via Discourse, work through assignments and exercises together, and have detailed walk-throughs of code in R and Stata. This is the prequel to the Part II course that covers difference-in-differences and synthetic control.


## Schedule

### Potential Outcomes

#### About
           
The modern theory of causality is based on a seemingly simple idea called the "counterfactual".  The counterfactual is an unusual features of the arsenal of modern statistics because it is more or less storytelling about alternative worlds that may or may not exist, but could have existed had one single decision gone a different way.  Out of this idea grew what a model, complete with its own language, on top of which the field of causal inference is based, and the purpose of this lecture is to learn that language.  The language is called potential outcomes and it forms the basis for many causal objects we tend to be interested in, such as the average treatment effect. I also cover randomization, selection bias and randomization inference.


#### Slides
           
<a href="https://github.com/Mixtape-Sessions/Causal-Inference-1/blob/main/Slides/01-Foundations.pdf">Foundations of causality</a>
<a href="https://github.com/Mixtape-Sessions/Causal-Inference-1/blob/main/Slides/01-Foundations-DAG.pdf">DAGs</a>

#### Code
           
[Doctor PO](https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/Doctor-PO)

[Replication of Thornton (2008)](https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/Thornton)

[Shiny App for Randomization Inference](https://mixtape.shinyapps.io/Randomization-Inference/)

#### Readings

Mixtape chapter 3: <a href="https://mixtape.scunning.com/potential-outcomes.html">Directed Acyclical Graphs</a>

Mixtape chapter 4: <a href="https://mixtape.scunning.com/potential-outcomes.html">Potential Outcomes Causal Model</a>





### Known and Quantified Confounder Methods

#### About

In observational studies, researchers typically are not able to assume that a treatment is randomly assigned as in an experiment. However, this randomization becomes more plausible in some cases after conditioning on a set of covariates. For example, it is not likely that attending college is random since individuals will sort to college based on a bunch of personal characteristics and social setting. However, comparing two individuals who have much of the same characteristics and come from similar backgrounds, it becomes more likely that whether these two individuals attend college differ. This is often called *selection on observables* and this section covers how to try to "match" two individuals based on their characteristics when you believe this assumption.

#### Slides

<a href="https://github.com/Mixtape-Sessions/Causal-Inference-1/blob/main/Slides/02-Known_Observed_Confounders.pdf">Known Observed Confounders</a>

#### Code

[Titanic exercise using stratification weighting] (see lab section under Titanic)

[Replication of Lalonde (1986) and Dehejia and Wahba (2002)](https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/Thornton)

#### Readings

Mixtape chapter 5: <a href="https://mixtape.scunning.com/matching-and-subclassification.html">Matching and Subclassification</a>






### Instrumental Variables

#### About

In settings where we are not willing to assume *selection on observables*, researchers often turn to an instrumental variables (IV) strategy to estimate a causal effect. In short, IVs are a sort of "external shock" to the equilibrium we're thinking about. This chapter shows how to leverage these "external shocks" to identify causal effects. 


#### Slides

<a href="https://github.com/Mixtape-Sessions/Causal-Inference-1/blob/main/Slides/03-IV.pdf">Instrumental Variables</a>

#### Code

[Replication of Graddy (1995) and Card (1995)](https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/IV)

#### Readings

Mixtape chapter 7: <a href="https://mixtape.scunning.com/instrumental-variables.html">Instrumental Variables</a>



### Regression Discontinuity Design

#### About
One of the most desired quasi-experimental designs -- desired because it is viewed as highly credible despite being based on observational data -- is the regression discontinuity design.  Here I will discuss the sharp RDD in great detail, going through identification, estimation, specification tests and tips, as well as a replication.

#### Slides

<a href="https://github.com/Mixtape-Sessions/Causal-Inference-1/blob/main/Slides/04-RDD.pdf">Regression Discontinuity Designs</a>


#### Code

[Replication of Hansen (2015)](https://github.com/Mixtape-Sessions/Causal-Inference-1/tree/main/Lab/DUI%20Recidivism)

[Shiny App for RD Optimal Bandwidth](https://mixtape.shinyapps.io/RD-Bandwidth/)


#### Readings

Mixtape chapter 6: <a href="https://mixtape.scunning.com/regression-discontinuity.html">Regression discontinuity</a>



