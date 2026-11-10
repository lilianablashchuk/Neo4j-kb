MATCH path = (c:Candidate {id: 'C001'})-[*1..4]-(target)
WHERE target:Recruiter OR target:Company
RETURN c.name AS Candidate, 
       labels(target)[0] AS StakeholderType, 
       target.name AS StakeholderName, 
       length(path) AS ImpactHops
ORDER BY ImpactHops ASC;