/* CRYSTAL CONTRERAS */
/* FINAL PROJECT ANALYSIC v1 */

DATA bank;
INFILE "cleaned-bank.csv" FIRSTOBS=2 DELIMITER=',';
INPUT i age job $ marital $ education $ default $ housing $ loan $ contact $ month $ day_of_week $ duration campaign pdays previous poutcome $ emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed y $;
DROP i; * index;
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











