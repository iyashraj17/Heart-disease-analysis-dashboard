
-- View first 10 rows
SELECT * FROM heart_data LIMIT 10;

-- Total number of records
SELECT COUNT(*) AS total_records FROM heart_data;

-- Unique values in categorical columns
SELECT DISTINCT anaemia, diabetes, high_blood_pressure, smoking, sex, DEATH_EVENT FROM heart_data;


-- Average age and ejection fraction
SELECT ROUND(AVG(age),2) AS avg_age, ROUND(AVG(ejection_fraction),2) AS avg_ejection_fraction FROM heart_data;

-- Count of patients by gender
SELECT sex, COUNT(*) AS total_patients FROM heart_data GROUP BY sex;


-- Patients who died and had diabetes
SELECT * FROM heart_data WHERE DEATH_EVENT = 'Yes' AND diabetes = 'Yes';

-- Patients older than 60 with high blood pressure
SELECT age, high_blood_pressure FROM heart_data WHERE age > 60 AND high_blood_pressure = 'Yes';


-- Death rate by gender
SELECT sex, COUNT(*) AS total,
       SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) AS deaths,
       ROUND(100.0 * SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS death_rate_percentage
FROM heart_data GROUP BY sex;

-- Death rate by age group
SELECT CASE WHEN age < 40 THEN 'Under 40'
            WHEN age BETWEEN 40 AND 60 THEN '40-60'
            ELSE 'Above 60' END AS age_group,
       COUNT(*) AS total,
       SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) AS deaths,
       ROUND(100.0 * SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS death_rate_percentage
FROM heart_data
GROUP BY age_group
ORDER BY death_rate_percentage DESC;


-- Average ejection fraction by survival status
SELECT DEATH_EVENT, ROUND(AVG(ejection_fraction), 2) AS avg_ejection_fraction
FROM heart_data GROUP BY DEATH_EVENT;

-- Average time until event by survival status
SELECT DEATH_EVENT, ROUND(AVG(time), 2) AS avg_followup_time
FROM heart_data GROUP BY DEATH_EVENT;

-- Top 10 patients with highest creatinine phosphokinase levels
SELECT age, sex, creatinine_phosphokinase, DEATH_EVENT
FROM heart_data
ORDER BY creatinine_phosphokinase DESC
LIMIT 10;

-- 6️⃣ MORE ADVANCED QUERIES
-- 6.1 Window Function: Rank patients by ejection fraction
SELECT age, sex, ejection_fraction,
       RANK() OVER (ORDER BY ejection_fraction DESC) AS ejection_rank
FROM heart_data;

-- 6.2 Rolling Average of ejection fraction by age group
SELECT age, sex, ejection_fraction,
       ROUND(AVG(ejection_fraction) OVER (PARTITION BY sex), 2) AS avg_ejection_by_sex
FROM heart_data;

-- 6.3 Correlation Insight: Death rate by combined conditions (diabetes + high blood pressure)
SELECT diabetes, high_blood_pressure,
       COUNT(*) AS total,
       SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) AS deaths,
       ROUND(100.0 * SUM(CASE WHEN DEATH_EVENT = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS death_rate
FROM heart_data
GROUP BY diabetes, high_blood_pressure
ORDER BY death_rate DESC;

-- 6.4 Patients with abnormal lab values (serum_creatinine > 1.5 OR serum_sodium < 135)
SELECT *
FROM heart_data
WHERE serum_creatinine > 1.5 OR serum_sodium < 135
ORDER BY serum_creatinine DESC, serum_sodium ASC;

-- 6.5 Identify patients at high risk based on combined conditions
SELECT age, sex, diabetes, high_blood_pressure, smoking, ejection_fraction, serum_creatinine,
       CASE 
           WHEN ejection_fraction < 30 OR serum_creatinine > 2 THEN 'High Risk'
           WHEN ejection_fraction BETWEEN 30 AND 40 THEN 'Moderate Risk'
           ELSE 'Low Risk'
       END AS risk_level
FROM heart_data
ORDER BY risk_level, age DESC;
