/* CRYSTAL CONTRERAS */
/* FINAL PROJECT ANALYSIC v1 */

* Import dataset;
DATA bank;
INFILE "cleaned-bank.csv" FIRSTOBS=2 DELIMITER=',';
INPUT i age job $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
* Drop the index column from our data since it is not needed;
DROP i;
* Create dummy variables for categorical attributes;
job1=(job='blue-collar');
job2=(job='services');
job3=(job='admin.');
job4=(job='self-employed');
job5=(job='technician');
job6=(job='management');
job7=(job='retired');
job8=(job='entrepreneur');
job9=(job='housemaid');
job10=(job='unemployed');
job11=(job='student');
marital1=(marital='married');
marital2=(marital='single');
marital3=(marital='divorced'); * could also mean widowed;
ed0=(education='illiterate');
ed1=(education='basic.4y');
ed2=(education='basic.6y');
ed3=(education='basic.9y');
ed4=(education='high.school');
ed5=(education='professional.course');
ed6=(education='university.degree');
credit_default=(default='yes'); * 1 = yes, 0 = no;
housing_loan=(housing='yes');
has_loan=(loan='yes');
cellphone=(contact='cellular'); * 0 = telephone;
* survey conducted between March - December;
month3=(month='mar');
month4=(month='apr');
month5=(month='may');
month6=(month='jun');
month7=(month='jul');
month8=(month='aug');
month9=(month='sep');
month10=(month='oct');
month11=(month='nov');
month12=(month='dec');
day1=(day_of_week='mon');
day2=(day_of_week='tue');
day3=(day_of_week='wed');
day4=(day_of_week='thu');
day5=(day_of_week='fri');
prev_outcome1=(poutcome='failure');
prev_outcome2=(poutcome='nonexistent');
prev_outcome3=(poutcome='success');
target=(y='yes');
RUN;
PROC PRINT;
RUN;

* Create a copy of the dataset that omits duplicate attributes - the ones we created dummy variables for; 
DATA bank_new;
SET bank;
DROP job marital education month default housing loan contact day_of_week poutcome y;
RUN;
TITLE "Bank New";
PROC PRINT;
RUN;

* Check the frequency of our target variable to ensure we have enough samples of each side;
PROC FREQ;
	TITLE "Dependent Variable's Frequency";
	TABLES target;
RUN;

/* We have 2720 samples of 'no' = 88% Probability,
   and 370 samples of 'yes' = 12% Probability. 
			odds(y=1) = 0.12/0.88 => The odds that event Y = 1 occurs is 0.136 to 1.  This means we have a higher chance of failure.
			odds(y=0) = 0.88/0.12 => 7.33  to 1 	(slide 8 of lecture 7)

	I predict this will affect our Probability, threshold, train/test split.
	1.  Find out what percentage of each Y value we should have in relation to our dataset.
		- Slide 35 of Lecture 7 states 10-30 cases per independent variable. 53 (w/dummy) * 10 = 530 observations we should have.
		" - Make sure it has enough observations for each case (1 & 0).
		If there isn't enough samples or there are many cells with no response, 
		parameter estimates and standard errors are likely to be unstable & maximum likelihodd estimation
		(MLE) of params could be impossible to obtain."
	2.  Either remove some observations of 'no', add in more 'yes' samples, or both. 
*/

* Run Logistic Regression on the full model;
PROC LOGISTIC;
	TITLE "Logistic Regression on Full Model";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / STB RSQUARE;
RUN;


* Run a selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Stepwise selection method";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=STEPWISE RSQUARE;
RUN;
/* RSQUARE = 0.2637 
Month5 (May) was seen as significant in the STEPWISE selection method. 
This is biased because it's the month with the most calls.
Month3 (March) followed as significant. It has the 2nd lowest frequency (good thing), 
but it's also the 1st month of the campaign. Finally, month6 (June) followed as significant. 
This month may also be biased because it has the 2nd highest frequency of calls.

The selection method chose 8 out of the 53 attributes, but the R2 value was only 0.2637.
I want to test if removing some observations would increase the Rsquare value, 
specifically observations that meet the following criteria:
- target = 0
- pdays = 999 (b/c 95% of our data is comprised of those values)
- month = 'may' (month w/the highest amount of calls)

Another option could be to add in more 'yes' samples from the full dataset to add 
more variance and increase the probability that event Y will occur.
*/



* Run Logistic Regression on the selected variables;
/*PROC LOGISTIC;
	TITLE "Stepwise selection method";
	MODEL target (event='1') = duration cons_conf_idx nr_employed cellphone month3 month5 month6 prev_outcome3  / RSQUARE;
RUN;*/

* Compare their Adj-R2 value, etc;

* Check for multicollinearity - Pearson Correlation;
* Check for outliers - Pearson or Deviance Residuals +-3;
* Check for influential points - DFBetas;
/* Create a new table that:
	- Removes outlier rows;
	- Removed rows with above-mentioned critera;
*/

* Run selection & logistic regression again to see if ADJ-R2 improved;
 
























