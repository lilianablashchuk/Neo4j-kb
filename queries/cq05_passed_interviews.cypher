MATCH (c:Candidate)-[:SUBMITTED]->(a:Application)-[:HAS_STAGE]->(i:Interview)
WHERE i.status = 'Passed'
RETURN c.name AS Candidate, a.id AS Application, i.stage AS Stage, i.interview_date AS Date
ORDER BY i.interview_date DESC;