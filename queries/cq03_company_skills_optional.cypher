MATCH (co:Company {name: 'SoftServe'})-[:POSTED]->(v:Vacancy)
OPTIONAL MATCH (v)-[:REQUIRES_SKILL]->(s:Skill)
RETURN v.title AS Vacancy, v.status AS Status, coalesce(collect(s.name), []) AS SkillsRequired;