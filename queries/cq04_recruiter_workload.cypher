MATCH (r:Recruiter)-[:MANAGES]->(v:Vacancy {status: 'Open'})
OPTIONAL MATCH (v)<-[:FOR_VACANCY]-(a:Application)
RETURN r.name AS Recruiter, 
       r.agency AS Agency, 
       count(DISTINCT v) AS OpenVacancies, 
       count(a) AS ActiveApplications
ORDER BY ActiveApplications DESC;