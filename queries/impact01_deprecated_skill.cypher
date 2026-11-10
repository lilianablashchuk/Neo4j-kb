MATCH path = (s:Skill {name: 'FastAPI'})<-[:REQUIRES_SKILL]-(v:Vacancy)<-[:FOR_VACANCY]-(a:Application)-[:HAS_STAGE]->(i:Interview)
RETURN s.name AS DeprecatedSkill, 
       v.title AS AffectedVacancy, 
       a.id AS ImpactedApplication, 
       i.stage AS ScheduledStage, 
       i.status AS InterviewStatus,
       length(path) AS Depth;