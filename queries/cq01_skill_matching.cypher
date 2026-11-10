MATCH (v:Vacancy {id: 'V001'})-[:REQUIRES_SKILL]->(s:Skill)<-[:HAS_SKILL]-(c:Candidate)
WHERE c.expected_salary <= v.max_salary
RETURN v.title AS Vacancy, 
       c.name AS Candidate, 
       c.expected_salary AS Salary, 
       collect(s.name) AS MatchedSkills
ORDER BY size(MatchedSkills) DESC, Candidate ASC;