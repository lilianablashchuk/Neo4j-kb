MATCH (c1:Candidate {id: 'C001'})-[:HAS_SKILL*2]-(c2:Candidate)
WHERE c1 <> c2
RETURN c1.name AS BaseCandidate, c2.name AS SimilarCandidate, count(*) AS CommonSkillsCount
ORDER BY CommonSkillsCount DESC
LIMIT 5;