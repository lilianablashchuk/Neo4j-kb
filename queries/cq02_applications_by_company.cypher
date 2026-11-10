MATCH (co:Company)-[:POSTED]->(v:Vacancy)<-[:FOR_VACANCY]-(a:Application)<-[:SUBMITTED]-(c:Candidate)
WITH co.name AS Company, count(a) AS ApplicationsCount, collect(DISTINCT c.name) AS Applicants
RETURN Company, ApplicationsCount, Applicants
ORDER BY ApplicationsCount DESC;