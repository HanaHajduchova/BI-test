SELECT 
    j.JobSK, 
    j.JobID, 
    j.ProjectNo, 
    b.SourceLanguageCode, 
    b.JobStateName, 
    b.Job, 
    b.CreatedDate, 
    b.CompletedDate, 
    COALESCE(SUM(t.Wordcount), 0) AS Wordcount, -- Total word count for the job, if available, otherwise 0
    CASE 
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'H' THEN 0
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'M' THEN 1
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'L' THEN 2
        ELSE 3
    END AS Priority, -- Job priority based on classification (H, M, L, or other)
    DATE(b.CompletedDate) AS CompletedDate, -- Convert CompletedDate to DATE type
    CASE 
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'H' THEN DATE(b.CreatedDate, '+1 day')
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'M' THEN DATE(b.CreatedDate, '+3 days')
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'L' THEN DATE(b.CreatedDate, '+5 days')
        ELSE DATE(b.CreatedDate, '+10 days')
    END AS DueDate, -- Estimated completion date based on classification
    CASE 
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'H' AND (b.CompletedDate IS NULL OR DATE(b.CompletedDate) <= DATE(b.CreatedDate, '+1 day')) THEN 'On-time'
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'M' AND (b.CompletedDate IS NULL OR DATE(b.CompletedDate) <= DATE(b.CreatedDate, '+3 days')) THEN 'On-time'
        WHEN COALESCE(NULLIF(b.Classification, ''), 'Empty') = 'L' AND (b.CompletedDate IS NULL OR DATE(b.CompletedDate) <= DATE(b.CreatedDate, '+5 days')) THEN 'On-time'
        WHEN b.CompletedDate IS NULL THEN 'Not Completed'
        ELSE 'Late'
    END AS DeliveryStatus -- Delivery status based on completion date (On-time, Not Completed, Late)
FROM 
    Job j
JOIN 
    Base b ON j.JobSK = b.JobSK -- Join tables Job and Base based on JobSK
LEFT JOIN 
    Tasks t ON j.JobID = t.JobID -- Left join with table Tasks based on JobID
WHERE 
    b.JobStateName != 'Canceled' -- Filter to exclude canceled jobs
GROUP BY 
    j.JobSK, 
    j.JobID, 
    j.ProjectNo, 
    b.SourceLanguageCode, 
    b.JobStateName, 
    b.Job, 
    b.CreatedDate, 
    b.CompletedDate, 
    Priority; -- Group by key columns and priority
