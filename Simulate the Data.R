#File to create the simulated data to be used for the MRP in Rstanarm project
#Creates a sample of 1000 from a clustered design with four variables to stratify on and
#one interaction
#Created Lauren Kennedy 6th of October, 2017

#Load the relevent libraries
library(ggplot2)
library(arm)
library(rstanarm)
library(dplyr)

#Set the working directory
setwd("~/Post Doc/MRP in rSTANarm")

#Create the toy data (this procedure taken from Andrew's book 'Regression and other Stories')

J <- c(2, 3, 7, 3, 50) #sex, eth, age, income level, state
poststrat <- as.data.frame(array(NA, c(prod(J), length(J)+1))) #Columns of post-strat matrix, plus one for size
colnames(poststrat) <- c("male", "eth", "age","income", "state",'N')
count <- 0
for (i1 in 1:J[1]){
  for (i2 in 1:J[2]){
    for (i3 in 1:J[3]){
      for (i4 in 1:J[4]){
        for (i5 in 1:J[5]){
            count <- count + 1
            poststrat[count, 1:5] <- c(i1-1, i2, i3,i4,i5) #Fill them in so we know what category we are referring to
        }
      }
    }
  }
}
#Proportion in each sample in the population
p_male <- c(0.52, 0.48)
p_eth <- c(0.5, 0.2, 0.3)
p_age <- c(0.2,.1,0.2,0.2, 0.10, 0.1, 0.1)
p_income<-c(.50,.35,.15)
p_state_tmp<-runif(50,10,20)
p_state<-p_state_tmp/sum(p_state_tmp)
poststrat$N<-0
for (j in 1:prod(J)){
  poststrat$N[j] <- round(250e6 * p_male[poststrat[j,1]+1] * p_eth[poststrat[j,2]] *
    p_age[poststrat[j,3]]*p_income[poststrat[j,4]]*p_state[poststrat[j,5]]) #Adjust the N to be the number observed in each category in each group
}

#Now let's adjust for the probability of response
p_response_baseline <- 0.01
p_response_male <- c(2, 0.8)/2.8
p_response_eth <- c(1, 1.2, 2.5)/3.7
p_response_age <- c(1,0.4, 1, 1.5,  3, 5, 7)/18.9
p_response_inc <- c(1, 0.9, 0.8)/2.7
p_response_state <- rbeta(50,1,1)
p_response_state <- p_response_state/sum(p_response_state)
p_response <- rep(NA, prod(J))
for (j in 1:prod(J)){
  p_response[j] <- p_response_baseline * p_response_male[poststrat[j,1]+1] *
  p_response_eth[poststrat[j,2]] * p_response_age[poststrat[j,3]]*
    p_response_inc[poststrat[j,4]]*p_response_state[poststrat[j,5]]
}

n <- 4626
people <- sample(prod(J), n, replace=TRUE, prob=poststrat$N*p_response)

## For respondent i, people[i] is that person's poststrat cell,
## some number between 1 and 32
n_cell <- rep(NA, prod(J))
for (j in 1:prod(J)){
  n_cell[j] <- sum(people==j)
}
print(cbind(poststrat, n_cell/n, poststrat$N/sum(poststrat$N)))

coef_male <- c(0, -0.3)
coef_eth <- c(0, 0.6, 0.9)
coef_age <- c(0, -0.2, -0.3, 0.4, 0.5,.7,.8,.9)
coef_income <- c(0, -0.2, 0.6)
coef_state<-c(0,round(rnorm(49,0,1),1))
coef_age_male<-t(cbind(
  c(0,.1,.23,.3,.43,.5,.6),
  c(0,-.1,-.23,-.5,-.43,-.5,-.6)))
true.popn <- data.frame(poststrat[,1:5],cat.pref=rep(NA, prod(J)))
for (j in 1:prod(J)){
  true.popn$cat.pref[j] <- invlogit(coef_male[poststrat[j,1]+1] +
                            coef_eth[poststrat[j,2]] +coef_age[poststrat[j,3]] +
                            coef_income[poststrat[j,4]] +coef_state[poststrat[j,5]] +
                            coef_age_male[poststrat[j,1]+1,poststrat[j,3]])
}


#sex, eth, age, income level, state, city
y <- rbinom(n, 1, true.popn$cat.pref[people])
male <- poststrat[people,1] 
eth <- poststrat[people,2]
age <- poststrat[people,3]
income <- poststrat[people,4]
state <- poststrat[people,5]

sample <- data.frame(cat.pref=y, male, age, eth,income,state,id=1:length(people))

#Make all numeric:
for (i in 1: ncol(poststrat)){
  poststrat[,i]<-as.numeric(poststrat[,i])
}
for (i in 1: ncol(true.popn)){
  true.popn[,i]<-as.numeric(true.popn[,i])
}
for (i in 1: ncol(sample)){
  sample[,i]<-as.numeric(sample[,i])
}

write.csv(poststrat, file='poststrat.csv')
write.csv(true.popn, file='simulated_prob.csv')
write.csv(sample, file='simulated_data.csv')



