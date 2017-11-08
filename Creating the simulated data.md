The simulated data were created to have four variables that we wish to post-stratify with. To reduce the complexity of this description and the connected analysis, we named them after common variables that people often wish to post-stratify on; gender, age group, ethnicity and income level. These variables are rarely independent, so we also create an interaction between gender and age.

We also created the data set so that it has a clustered design, with individuals clustered into different cities, which were also clustered in different states. This reflects common sampling schemes in survey based research. Although the cities cluster is not included in the analysis, we chose to leave it in the file. 

The data were created in the script ``Simulate the data.Rdata``. In the rest of this appendix I summarise the steps for the creating the data to allow the reader to find the script more accessible. Each section in the script is separated so that it corresponds to a paragraph in this section. 

The first stage of the creation was to produce a post-stratification data-frame so that each row represents a unique combination post-stratification levels. We use four post stratification variables with levels ranging from two to five (2, 4, 5, 5). We also included variables that represented states (5 levels) and cities (9 levels). A full set of all possible combinations is 9,000. 

The next stage is to fill in proportion of people in each cell of the post-stratification matrix. Due to the clustered experimental design, many of the combinations will zero. Cities can only belong to one state, so if the individual is in one of the other states, the proportion of individuals in cities that are not in the state will be, by default, zero. The matrix of non-zero proportions is $1,800$. Once we have the proportion of people in each cell, we multiply by the number of people in the population to obtain the number of people in each sub-category. This forms our post-stratification matrix, which is representative of the *population*.

From this we need to create our *sample* data. The point of this analysis is that the sample is **not** representative of the population but instead has some sort of bias in the probability of obtaining a response. This could be due to sampling bias or response bias or some other factor. 

The outcome of the previous step is a column of the proportion of people who will respond to the survey given their subcategory. Given the size of the survey (in this data set 10,000), we randomly sample from the subcategories accordingly.

At this stage we have a set of people who belong to the different sub-categories of our post-stratification variables. Next we create a set of vectors that represent the preference for cats given each level of each subcategory, as well as a matrix that represents the interaction in preference for cats between age and gender. 

Finally we have all of the necessary ingredients to create a dataframe where each row represents a fictional participant in the study,  post-stratification cell they belong to and whether they said they preferred cats or not. 

