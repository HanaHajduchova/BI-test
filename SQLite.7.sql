-- Selecting columns from the Tasks table along with computed values and related information from the Job and Base tables
SELECT 
    t.JobID, 
    t.TaskID, 
    t.CreatedDate, 
    t.CompletedDate, 
    -- Calculating the due date based on the priority of the associated job
    CASE 
        WHEN b.Priority = 'High' THEN DATE(b.CreatedDate, '+1 day')
        WHEN b.Priority = 'Medium' THEN DATE(b.CreatedDate, '+3 days')
        WHEN b.Priority = 'Low' THEN DATE(b.CreatedDate, '+5 days')
        ELSE DATE(b.CreatedDate, '+10 days')
    END AS DueDate, -- Estimated due date for the task
    b.Priority, -- Priority of the associated job
    -- Determining the delivery status of the task based on completion date and job priority
    CASE 
        WHEN t.CompletedDate IS NULL OR t.CompletedDate = '' THEN 'Not Completed' -- Task not completed
        WHEN b.Priority = 'High' AND (t.CompletedDate <= DATE(b.CreatedDate, '+1 day')) THEN 'On-time' -- High priority task completed on time
        WHEN b.Priority = 'Medium' AND (t.CompletedDate <= DATE(b.CreatedDate, '+3 days')) THEN 'On-time' -- Medium priority task completed on time
        WHEN b.Priority = 'Low' AND (t.CompletedDate <= DATE(b.CreatedDate, '+5 days')) THEN 'On-time' -- Low priority task completed on time
        ELSE 'Late' -- Task completed late
    END AS DeliveryStatus -- Delivery status of the task
FROM 
    Tasks t -- Selecting from the Tasks table
JOIN 
    Job j ON t.JobID = j.JobID -- Joining with the Job table based on JobID
JOIN 
    Base b ON j.JobSK = b.JobSK -- Joining with the Base table based on JobSK
WHERE 
    j.isCurrent <> 0; -- Filtering out records where isCurrent is not equal to 0
