/************************
SPRING 2021 DSC 423 FINAL PROJECT ON PORTEGUESE BANK DATASET
MORGAN CHO
CRYSTAL CONTRERAS
TODD LEHKY
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
	IF _n_ IN (94, 190, 219, 406, 416, 860, 940, 969, 1012, 1093, 1012, 1119, 1323, 1448, 1499, 1500, 1580, 1693, 1797, 2143, 3082) THEN DELETE;
RUN;
PROC PRINT;
RUN;

* Run selection & logistic regression again to see if metrics improved;
PROC LOGISTIC;
	TITLE "Logistic Regression w/Removed outliers (M3)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx cellphone month3 month6 month8 prev_outcome3  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;
 

/***********************
From here on out, we used a smaller dataset to see if that would improve our model.
************************/

/* SMALLER BANK DATASET START */
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

* MULTICOLLINEARITY found between NR_EMPOLYED, CONS_PRICE_IDX & EMP_VAR_RATE;
* Removing NR_EMPOLYED & rerunning model;
PROC LOGISTIC;
	TITLE "Logistic Regression w/Backwards Selected variables - Small Bank 2 (M9)";
	MODEL target (event='1') = duration emp_var_rate cons_price_idx cons_conf_idx ed1 cellphone month3 month8 month9 month10 prev_outcome1  / RSQUARE STB CORRB IPLOTS INFLUENCE;
RUN;

* 6.	Determine/justify if removal of outliers and influential points are necessary;
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


* 7.	Split data into training and testing sets for model generation;
PROC SURVEYSELECT data=small_bank2_new2 OUT=train_test seed=949 samprate=60 outall;
RUN;
PROC PRINT;
RUN;

* check to see if the train/test split was done correctly;
PROC FREQ;
TABLES selected;
RUN;

* Compute new variable train_y=target for training set, and NA for test set;
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
* - Fit the final model, compute predicted value on training set, obtain the cut-off value for p;
PROC LOGISTIC;
	TITLE "M12 FINAL MODEL with training set";
	*generate the classification table to compute the cutoff value;
	MODEL train_y(event='1')= duration cons_conf_idx nr_employed cellphone month3 month6 month8 / ctable pprob=(0.1 to 0.8 by 0.05);
	OUTPUT out=pred (where = (train_y = .)) p=phat lower=lcl upper=ucl;
RUN;

* 5b. Compute predicted Y in testing set for pred_prob > 0.35;
DATA probs;
SET pred;
pred_y=0;
*modify threshold here;
if (phat >= 0.35) THEN pred_y = 1;
RUN;
PROC PRINT;
RUN;

*6.	Compute Confusion/Classification matrix;
PROC FREQ;
TABLES target*pred_y / norow nocol nopercent;
RUN;


