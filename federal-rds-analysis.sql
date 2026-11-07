USE US_OpenFedSpend;

-- Display the first 10 federal contract records
SELECT *
FROM awards
LIMIT 10;

-- Examine missing and zero total outlay values
SELECT
    COUNT(*) AS total_records,
    SUM(totalOutlays IS NULL) AS null_totalOutlays,
    SUM(totalOutlays = 0) AS zero_totalOutlays
FROM awards;

-- Check Awarding Agency Frequency Distribution
SELECT
    awardingAgency,
    COUNT(*) AS frequency
FROM awards
WHERE awardingAgency IS NOT NULL
    AND awardingAgency <> ''
GROUP BY awardingAgency
ORDER BY frequency DESC;

-- Check Contract Length Frequency Distribution
SELECT
    contractLength,
    COUNT(*) AS frequency
FROM awards
WHERE contractLength IS NOT NULL
GROUP BY contractLength
ORDER BY
    CASE
        WHEN contractLength = 'Short' THEN 1
        WHEN contractLength = 'Medium' THEN 2
        WHEN contractLength = 'Long' THEN 3
    END;
    
-- Check Earliest and latest contract start dates
SELECT
    MIN(startDate) AS earliest_start_date,
    MAX(startDate) AS latest_start_date
FROM awards
WHERE startDate IS NOT NULL;

-- Check Contract frequency by start year
SELECT
    YEAR(startDate) AS start_year,
    COUNT(*) AS frequency
FROM awards
WHERE startDate IS NOT NULL
GROUP BY YEAR(startDate)
ORDER BY start_year;

-- Award Amount Summary Statistics
SELECT
    AVG(awardAmount) AS mean_award,
    MIN(awardAmount) AS minimum_award,
    MAX(awardAmount) AS maximum_award,
    STDDEV(awardAmount) AS standard_deviation_awards
FROM awards
WHERE awardAmount IS NOT NULL;

-- Median Federal Contract Award Amount
WITH RankedAwards AS (
    SELECT
        awardAmount,
        ROW_NUMBER() OVER (
            ORDER BY awardAmount ASC
        ) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM awards
    WHERE awardAmount IS NOT NULL
)
SELECT
    AVG(awardAmount) AS median_award
FROM RankedAwards
WHERE RowNum IN (
    FLOOR((TotalRows + 1) / 2),
    FLOOR((TotalRows + 2) / 2)
);

-- 25th Percentile of Federal Contract Awards
WITH RankedAwards AS (
    SELECT
        awardAmount,
        ROW_NUMBER() OVER (
            ORDER BY awardAmount ASC
        ) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM awards
    WHERE awardAmount IS NOT NULL
)
SELECT
    AVG(awardAmount) AS percentile_25
FROM RankedAwards
WHERE RowNum = FLOOR(0.25 * TotalRows);

-- 75th Percentile of Federal Contract Awards
WITH RankedAwards AS (
    SELECT
        awardAmount,
        ROW_NUMBER() OVER (
            ORDER BY awardAmount ASC
        ) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM awards
    WHERE awardAmount IS NOT NULL
)
SELECT
    AVG(awardAmount) AS percentile_75
FROM RankedAwards
WHERE RowNum = FLOOR(0.75 * TotalRows);