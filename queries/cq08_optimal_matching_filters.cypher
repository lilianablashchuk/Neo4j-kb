MATCH (c:Candidate)-[:HAS_SKILL]->(s:Skill)<-[:REQUIRES_SKILL]-(v:Vacancy)
WHERE c.experience_years >= 3 
  AND c.expected_salary >= v.min_salary 
  AND c.expected_salary <= v.max_salary
RETURN v.title AS Vacancy, 
       v.min_salary AS Min, 
       v.max_salary AS Max,
       c.name AS Candidate, 
       c.experience_years AS Exp, 
       c.expected_salary AS Salary,
       collect(s.name) AS MatchingSkills;