# Understanding Omitted Variable Bias

## What is Omitted Variable Bias?

Omitted Variable Bias occurs when a regression model leaves out an important variable (confounder) that affects both the dependent variable (outcome) and one or more included independent variables (e.g. treatment). This leads to a biased estimate of the effect of the included variables.
This tool visualizes the bias for a simple example model.

In this 3D visualization:

- The **blue plane** represents the true model (including $\mathbf{Z}$).
- The **red plane** represents the underspecifed (potentially biased) model (omitting $\mathbf{Z}$).
- The **Y-axis (vertical) distance** between the two planes at a point $(x,y)$ represents the **bias for predictions**. 
- The **difference in slopes** of the planes **along the X and Y axes**  is the **bias for the coefficient of interest** $\beta_1$.

The bias varies across different values of $\mathbf{X}$ and $\mathbf{Z}$, illustrating how the omission of the confounding variable distorts our understanding of the true causal relationship.
- Rotating the plot helps to see the fit of the planes, and inspect the underlying univariate relationships.
- You can zoom and rotate using the plotly-controls on the top-right. 

## Causal Structure

In this visualization, we have the following random variables:
  
  - $\mathbf{X}$: Treatment or explanatory variable (what we're interested in)
- $\mathbf{Y}$: Outcome variable (what we're trying to predict)
- $\mathbf{Z}$: Omitted variable (or confounder)
- $\mathbf{U}$: Error term with $E[\mathbf{U}] = 0$ and independent of $X$ and $Z$.

The true causal structure is:
  
  1. $\mathbf{X}$ directly affects $\mathbf{Y}$ (the causal effect we want to estimate)
2. $\mathbf{Z}$ affects $\mathbf{X}$ (the confounder influences our treatment)
3. $\mathbf{Z}$ affects $\mathbf{Y}$ (the confounder directly influences our outcome)

## The Bias Mechanism

When we omit $\mathbf{Z}$ from our model, the estimated effect of $\mathbf{X}$ on $\mathbf{Y}$ is biased if both of the following conditions are fulfilled:
  
  1. $\mathbf{X}$ is correlated with $\mathbf{Z}$ (because $\mathbf{Z}$ affects $\mathbf{X}$)
2. $\mathbf{Z}$ directly affects $\mathbf{Y}$
  
  In this case, $\mathbf{X}$ captures some of $\mathbf{Z}$'s effect on $\mathbf{Y}$ through their correlation.


Mathematically, if the true model is:

$$\mathbf{Y} = \beta_0 + \beta_1 \mathbf{X} + \beta_2 \mathbf{Z} + \mathbf{U}$$

But we estimate the underspecified model:

$$\mathbf{Y} = \beta_0^* + \beta_1^* \mathbf{X} + \mathbf{U^*}$$

Then the expected value of the estimated coefficient is:

$$E[\beta_1^*] = \beta_1 + \beta_2 \cdot \frac{\text{Cov}(\mathbf{X},\mathbf{Z})}{\text{Var}(\mathbf{X})}$$

The bias term is:

$$\beta_2 \cdot \frac{\text{Cov}(\mathbf{X},\mathbf{Z})}{\text{Var}(\mathbf{X})}$$

Experiment with the sliders for $\beta_2$ and $\text{Cov}(\mathbf{X},\mathbf{Z})$ to see how the bias changes.


## Direction of Bias

The direction of the bias depends on:

1. The sign of $\beta_2$ (the effect of $\mathbf{Z}$ on $\mathbf{Y}$)
2. The sign of the correlation between $\mathbf{X}$ and $\mathbf{Z}$

- If $\beta_2 > 0$ and $\text{Corr}(\mathbf{X},\mathbf{Z}) > 0$, the bias is **positive** (overestimation)
- If $\beta_2 > 0$ and $\text{Corr}(\mathbf{X},\mathbf{Z}) < 0$, the bias is **negative** (underestimation)
- If $\beta_2 < 0$ and $\text{Corr}(\mathbf{X},\mathbf{Z}) > 0$, the bias is **negative** (underestimation)
- If $\beta_2 < 0$ and $\text{Corr}(\mathbf{X},\mathbf{Z}) < 0$, the bias is **positive** (overestimation)


