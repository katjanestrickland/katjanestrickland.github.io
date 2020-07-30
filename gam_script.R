#### STEP 1




library(tidyverse)
library(DataExplorer)
library(gridExtra)
####################
#Step 1: Clean Data

#inspect data
load("data/NewHomeless.rdata")
homeless <- homeless

#count the missing data values
sapply(homeless, function(x) sum(is.na(x)))
which(is.na(homeless$PropVacant))

# #inspect missing values
# missing <- homeless %>%
#   filter(is.na(PropVacant))

#impute the missing data
homeless[is.na(homeless)] = 0

#cleanign up the mis coded
# Adjust values of PropMinority mis-coded as "100" instead of "1.0"
library(dplyr)
homeless <- mutate_at(homeless, vars(PropMinority), list(~ ifelse( . > 1.0, 1.0, .)))

# Convert values of "Pct" variables to be in decimal scale
homeless <- mutate_at(homeless, vars(PctResidential:PCTIndustrial), list(~ .*.01))

# Recode four NAs in PropVacant as zero owing to how few residential dwellings exist in
# those tracts
homeless <- mutate_at(homeless, vars(PropVacant), list(~ ifelse(is.na(.)==T, 0, .)))

#recode the industrial
homeless <- homeless %>%
  mutate(Industrial = ifelse(PCTIndustrial >0, 1, 0))

####################
#Step 2: Univariate Statistics

library(DataExplorer)
#pairs
# pairs(homeless)
# #correlation
# plot_correlation(homeless, type = 'continuous','Review.Date')

#Street Total

par(mfrow = c(1,2))
p1 <- ggplot(aes(StreetTotal), data = homeless) +
  geom_histogram(binwidth = 6) +
  geom_vline(xintercept = mean(homeless$StreetTotal), colour = "pink")
p2 <- ggplot(aes(MedianIncome), data = homeless) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = mean(homeless$MedianIncome), colour = "pink")
#Prop Vacant
p3 <- homeless %>%
  ggplot(aes(PropVacant)) +
  geom_histogram(bins = 40) +
  geom_vline(xintercept = mean(homeless$PropVacant), colour = "pink")
#Prop Minority
p4 <- homeless %>%
  ggplot(aes(PropMinority)) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = mean(homeless$PropMinority), colour = "pink")
#Pct Residential
p5 <- homeless %>%
  ggplot(aes(PctResidential)) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = mean(homeless$PctResidential), colour = "pink")
#PctCommercial
p6 <- homeless %>%
  ggplot(aes(PctCommercial)) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = mean(homeless$PctCommercial), colour = "pink")
#PctIndustrial
p7 <- homeless %>%
  ggplot(aes(PCTIndustrial)) +
  geom_histogram(bins = 50) +
  geom_vline(xintercept = mean(homeless$PCTIndustrial), colour = "pink")
library(gridExtra)
grid.arrange(p1, p2, p3, p4, p5, p6, p7, nrow = 3)

#set seed at 4000
# Bring in data and create initial training and test datasets
set.seed(4000)
df <- homeless
index <- sample(1:nrow(df), (nrow(df))/2, replace = F) 
Train <- na.omit(df[index,]) # Training data
Test <- na.omit(df[-index,]) # Test data
##coming to the right model:
library(leaps)
All1 <- regsubsets(StreetTotal ~ MedianIncome + PropMinority +
                     PropVacant+
                     PctResidential+
                     PCTIndustrial +
                     PctCommercial +
                     Industrial, data = Train)
# All1
# summary(All1)

Model2 <- lm(StreetTotal ~  
               PropVacant+
               Industrial +
               (PropVacant:Industrial), data = Train)
# summary(Model2)

## Generalization error ##
# Specify a model on the testing data 
Model2 <- lm(StreetTotal ~  
               PropVacant+
               Industrial +
               (PropVacant:Industrial), data = Test)
summary(Model2)
#estimate the fitted values on the testing data, and the generalization error
preds <- predict(Model2, newdata = Test) # New fitted values derived from the test data
GE <- var(Test$StreetTotal - preds) # Estimate of generalization error (the variance of the residuals when 
GE
sqrt(GE)
# Bootstrap a confidence interval for the generalization error 
bootstrap_genError <-
  function(x) {
    bootstrapped_genErrors <- 0
    for (i in 1:1000) {
      index <- sample(1:nrow(x), nrow(x), replace = T)
      sample_Test <- x[index,]
      sample_Test_preds <- predict(Model2, newdata = sample_Test)
      bootstrapped_genErrors[i] <- var(sample_Test$StreetTotal - sample_Test_preds)
    }
    return(bootstrapped_genErrors)
  }

bootstrap_results_ge <- bootstrap_genError(Test)

# Check generalization error bootstrap results
# mean(bootstrap_results_ge, na.rm = T)
# summary(bootstrap_results_ge)
# hist(bootstrap_results_ge, breaks = 20) 
# qqnorm(bootstrap_results_ge)
# sd(bootstrap_results_ge)
# quantile(bootstrap_results_ge, probs = c(.025,.975))
# plot(density(bootstrap_results_ge))
# qqnorm(bootstrap_results_ge)
#use robust sandwich standard errors in the sandwich package
# install.packages("sandwich")
library(sandwich)
vcovHC(Model2, type = "HC")
sandwich_se <- diag(vcovHC(Model2, type = "HC1"))
sqrt(sandwich_se)
#then can get the confidence interval limits of these
# coef(Model2) - 1.96*sandwich_se
# coef(Model2) + 1.96*sandwich_se







### STEP 2




library(gam)
library(mgcv)
library(leaps)

homeless2 <- homeless %>%
  filter(MedianIncome > 60000 & PropVacant < .10)

##MODEL 1
out3 <- gam(StreetTotal ~
              s(PCTIndustrial) +
              s(PctCommercial) +
              s(PropVacant) +
              s(MedianIncome), data = homeless, family = gaussian)
# summary(out3)
par(mfrow=c(2,2))
plot(out3, residual = T, cex = 1, pch = 19, shade = T, shade.col = "light blue",
     col = "#FAD7A0")
library(mgcViz)
b<- getViz(out3)
o <- plot( sm(b, 1) )
o + l_fitLine(colour = "#FAD7A0") + l_rug(mapping = aes(x=x, y=y), alpha = 0.9) +
  l_ciLine(mul = 5, colour = "light blue", linetype = 2) + 
  l_points(shape = 19, size = 1, alpha = 0.7, color = "light blue") + theme_classic()

