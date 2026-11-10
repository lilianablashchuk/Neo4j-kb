MATCH (c:Candidate {id: 'C001'}), (r:Recruiter)
MATCH p = shortestPath((c)-[*]-(r))
RETURN r.name AS Recruiter, 
       length(p) AS PathDistance, 
       [n IN nodes(p) | coalesce(n.name, n.title, n.id)] AS PathNodes
LIMIT 1;