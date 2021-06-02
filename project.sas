/************************
SPRING 2021 DSC 423 FINAL PROJECT ON PORTEGUESE BANK DATASET
MORGAN CHO
CRYSTAL CONTRERAS
TODD LEHKY
KEERTHI MIRAJKAR
ROSHEN SAMUEL
*************************/

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
		parameter estimates and standard errors are likely to be unstable & maximum likelihood estimation
		(MLE) of params could be impossible to obtain."
	2.  Either remove some observations of 'no', add in more 'yes' samples, or both. 
*/

* Explore data to check for multicollinearity amongst independent, non-categorical variables;
PROC CORR;
	TITLE "Pearson Correlation Coefficients of Independent Variables";
	VAR age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed;
RUN;

* Run Logistic Regression on the full model;
PROC LOGISTIC;
	TITLE "Logistic Regression on Full Model";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / STB RSQUARE;
RUN;

* Run backward selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Backwards selection method";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=BACKWARD RSQUARE STB;
RUN;

* Run stepwise selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Stepwise selection method";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=STEPWISE RSQUARE STB;
RUN;

/* Month5 (May) was seen as significant in the STEPWISE selection method. 
This is biased because it's the month with the most calls.
Month3 (March) followed as significant. It has the 2nd lowest frequency (good thing), 
but it's also the 1st month of the campaign. Finally, month6 (June) followed as significant. 
This month may also be biased because it has the 2nd highest frequency of calls.

The selection method chose 8 out of the 53 attributes, but the R2 value was only 0.2637.
TODO: test later if removing 33% of observations would increase the Rsquare value, 
specifically observations that meet the following criteria:
- target = 0
- pdays = 999 (b/c 95% of our data is comprised of those values)

Another option could be to add in more 'yes' samples from the full dataset to add 
more variance and increase the probability that event Y will occur.
*/

* Compare their Adj-R2 value, etc;
	* Backwards selelction won.  See Project_Analysis.docx;


* Run Logistic Regression on the selected variables;
* Check for multicollinearity - Pearson Correlation;
	* Requires CORRB option at the end of PROC LOGISTIC MODEL;
* Check for outliers - Pearson or Deviance Residuals +-3;
	* Requires IPLOTS option;
* Check for influential points - DFBetas;
	* Requires INFLUENCE option;
PROC LOGISTIC;
	TITLE "Logistic Regression on Backward selection method's predictors";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx cellphone month3 month6 month8 prev_outcome3  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;

* Create a new table that removes outlier rows;
DATA bank_new2;
	TITLE "Bank data w/ removed outliers";
	SET bank_new;
	IF _n_ IN (1093, 1012, 1119, 1323, 1448, 1499, 1500, 1580, 1693, 1797, 3082) THEN DELETE;
RUN;
PROC PRINT;
RUN;

* Run selection & logistic regression again to see if metrics improved;
PROC LOGISTIC;
	TITLE "Logistic Regression w/Removed outliers (M3)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx cellphone month3 month6 month8 prev_outcome3  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;
 

* Create a new table that removes outliers 2;
DATA bank_new2;
	TITLE "Bank data w/ removed outliers 2";
	SET bank_new2;
	IF _n_ IN (531, 712, 860, 940,  1835, 1860) THEN DELETE;
RUN;
* Run selection & logistic regression again to see if metrics improved;
PROC LOGISTIC;
	TITLE "Logistic Regression w/removed outliers (M4)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx cellphone month3 month6 month8 prev_outcome3  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;
 
* Before I continue improving the model, I'm going to test if a smaller dataset size improves our model;

/***********************
TODO TEAM:
INCLUDE ANYTHING THAT IS MISSING FROM OUR ANALYSIS OF THE DATASET PRIOR TO SMALLER BANK DATASET ANALYSIS.
************************/


/* SMALLER BANK DATASET START */
* Create a new table that removes rows with above-mentioned critera;
* SMALL-BANK2 WINS: 1090 observations, small_bank2, backwards selection;
DATA small_bank2;
INFILE "small-bank2.csv" FIRSTOBS=2 DELIMITER=',';
INPUT i age job $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
DROP i;
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
marital3=(marital='divorced'); 
ed0=(education='illiterate');
ed1=(education='basic.4y');
ed2=(education='basic.6y');
ed3=(education='basic.9y');
ed4=(education='high.school');
ed5=(education='professional.course');
ed6=(education='university.degree');
credit_default=(default='yes'); 
housing_loan=(housing='yes');
has_loan=(loan='yes');
cellphone=(contact='cellular');
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

DATA small_bank2_new;
	TITLE "Small Bank New 2";
	SET small_bank2;
	DROP job marital education month default housing loan contact day_of_week poutcome y;
RUN;
PROC PRINT;
RUN;

* 1.	Create correlation matrices to observe multicollinearity amongst independent, non-categorical variables;
PROC CORR;
	TITLE "Pearson Correlation Coefficients of Independent Variables";
	VAR age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed;
RUN;

* 2.	Fit full regression model with all significant variables; 
* Analyze parameter estimates, significance, goodness-of-fit, and Adj. R2 values.;
PROC LOGISTIC;
	TITLE "Logistic Regression on Full Model with Diagnostics";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / STB RSQUARE CORRB IPLOTS INFLUENCE;
RUN;

* 3.	Apply various selection methods to find a subset of optimal predictors;
* Run backward selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Backwards selection method on Bank Small New 2";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=BACKWARD RSQUARE STB;
RUN;

* Run stepwise selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Stepwise selection method on Bank Small New 2";
	MODEL target (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=STEPWISE RSQUARE STB;
RUN;

* 4. Determine if multi-collinearity among the independent variables is of significant concern using CORRB option;
* 5. Analyze residual plots to check for outliers;
PROC LOGISTIC;
	TITLE "Logistic Regression w/Backwards Selected variables - Small Bank 2";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx nr_employed ed1 cellphone month3 month8 month9 month10 prev_outcome1  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;
* MULTICOLINEARITY found between NR_EMPOLYED, CONS_PRICE_IDX & EMP_VAR_RATE;
* Removing NR_EMPOLYED & rerunning model;
PROC LOGISTIC;
	TITLE "Logistic Regression w/Backwards Selected variables - Small Bank 2 (M9)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx ed1 cellphone month3 month8 month9 month10 prev_outcome1  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;


* 6.	Determine/justify if removal of outliers and influential points are necessary;
* Since we have an abundance of data, I'd say we're justified in removing a few outliers (see jupyter notebook for full view of each of the observations);
DATA small_bank2_new2;
	TITLE "Small Bank data w/ removed outliers";
	SET small_bank2_new;
	IF _n_ IN (1082, 1045, 418, 320, 318, 261, 248, 230, 26, 66, 11) THEN DELETE;
RUN;
PROC PRINT;
RUN;

PROC LOGISTIC;
	TITLE "Logistic Regression w/Backwards Selected variables - Small Bank 2 (M10)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx ed1 cellphone month3 month8 month9 month10 prev_outcome1  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;
* more outliers to remove;
DATA small_bank2_new2;
	TITLE "Small Bank data w/ removed outliers 3";
	SET small_bank2_new2;
	IF _n_ IN (938, 892, 848, 679, 658, 639, 551, 500, 136) THEN DELETE;
RUN;
PROC PRINT;
RUN;

PROC LOGISTIC;
	TITLE "Logistic Regression w/Backwards Selected variables - Small Bank 2 (M10)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx ed1 cellphone month3 month8 month9 month10 prev_outcome1  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;

* Check the frequency of our target variable to ensure we have enough samples of each side;
PROC FREQ data=small_bank2_new2;
	TITLE "Dependent Variable's Frequency";
	TABLES target;
RUN;
/* We have 706 samples of 'no' = 65.98% Probability,
   and 364 samples of 'yes' = 34.02% Probability. 
			odds(y=1) = 0.34/0.66 => The odds that event Y = 1 occurs is 0.515 to 1.  This means we have a higher chance of failure.
			odds(y=0) = 0.66/0.34 => 1.94  to 1 Higher chance of failure.	(slide 8 of lecture 7) */

*7.	Verify the strongest/most influential predictors for the response variable;

*8.	Split data into training and testing sets for model generation;
PROC SURVEYSELECT data=small_bank2_new2 OUT=train_test seed=949 samprate=60 outall;
RUN;
PROC PRINT;
RUN;

* check to see if the train/test split was done correctly;
PROC FREQ;
TABLES selected;
RUN;

* Compute new variable new_y=target for training set, and NA for test set;
DATA train_test;
SET train_test;
IF selected THEN train_y=target;
RUN;
PROC PRINT;
RUN;

* Check frequency of target in this dataset to verify we have enough Y=1;
PROC FREQ;
TABLES train_y;
RUN;

* Run selection method on training set, use train_y instead of target variable;
* Run stepwise selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Stepwise selection - Bank Small New 2 - train_y (M12)";
	MODEL train_y (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=STEPWISE RSQUARE STB;
RUN;

* Run backward selection method for logistic regression;
PROC LOGISTIC;
	TITLE "Backwards selection - Bank Small New 2 - train_y (M13)";
	MODEL train_y (event='1') = age duration campaign pdays previous emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed job1 job2 job3 job4 job5 job6 job7 job8 job9 job10 job11 marital1 marital2 marital3 ed0 ed1 ed2 ed3 ed4 ed5 ed6 credit_default housing_loan has_loan cellphone month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 day1 day2 day3 day4 day5 prev_outcome1 prev_outcome2 prev_outcome3  / SELECTION=BACKWARD RSQUARE STB;
RUN;

/* VALIDATION METHOD */
*1.	Compute the PRESS values and cross-validate across n models, where n is equal to the number of independent variables. 
Eliminate predictors that are not significant in a majority of the generated models. 
Verify ASE plot and values to determine performance.;
* Final Model selected uses predictors: duration cons_conf_idx nr_employed cellphone month3 month6 month8.
See excel spreadsheet for stats;
*2.	Use the fitted regression model to predict the dependent variable. 
Using SAS to compute the predicted dependent variable, 95% confidence interval and prediction interval for our estimate;
*3.	Calculate Sensitivity & specificity for final project.  Do accuracy and precision too (might as well). 
Sensitivity important to our predicted y = 1 (yes);
* - Fit the final model, compute predicted value on training set, obtain the cut-off value for p;
PROC LOGISTIC;
	TITLE "M12 FINAL MODEL with training set";
	*generate the classification table to compute the cutoff value;
	MODEL train_y(event='1')= duration cons_conf_idx nr_employed cellphone month3 month6 month8 / ctable pprob=(0.1 to 0.8 by 0.05);
	OUTPUT out=pred (where = (train_y = .)) p=phat lower=lcl upper=ucl;
RUN;
* Our cutoff/threshold value of .34 is very close to the Probability level with the highest
F1 score (sensitivity + Specificity), which was P of 0.35 at F1 score of 174.4;

* 5b. Compute predicted Y in testing set for pred_prob > 0.35;
* should increase True Positives --> try 0.35, 0.3, 0.2 threshold values;
DATA probs;
SET pred;
pred_y=0;
*modify threshold here;
if (phat >= 0.35) THEN pred_y = 1;
RUN;
PROC PRINT;
RUN;

*4.	Compute Confusion/Classification matrix;
PROC FREQ;
TABLES target*pred_y / norow nocol nopercent;
RUN;


