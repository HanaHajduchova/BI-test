-- Selecting JobIDs from the Job table
SELECT 
    j.JobID
FROM 
    Job j
-- Left joining tables Job and Base based on JobSK
LEFT JOIN 
    Base b ON j.JobSK = b.JobSK
-- Left joining tables Job and Tasks based on JobID
LEFT JOIN 
    Tasks t ON j.JobID = t.JobID
WHERE 
    j.isCurrent = 0 -- Filtering jobs where isCurrent is 0
GROUP BY 
    j.JobID -- Grouping by JobID
HAVING 
    COUNT(t.TaskID) = 0; -- Filtering out jobs with no associated tasks
