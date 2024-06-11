-- Calculating the percentage of records with 'EN-US' as the SourceLanguageCode
SELECT 
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Base)) AS Percentage -- Calculating the percentage
FROM 
    Base -- Selecting from the Base table
WHERE 
    SourceLanguageCode = 'EN-US'; -- Filtering records where the SourceLanguageCode is 'EN-US'
