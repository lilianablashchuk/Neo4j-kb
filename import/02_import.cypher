
LOAD CSV WITH HEADERS FROM 'file:///candidates.csv' AS row
MERGE (c:Candidate {id: row.id})
ON CREATE SET c.name = row.name,
              c.experience_years = toInteger(row.experience_years),
              c.expected_salary = toInteger(row.expected_salary),
              c.city = row.city;

LOAD CSV WITH HEADERS FROM 'file:///skills.csv' AS row
MERGE (s:Skill {id: row.id})
ON CREATE SET s.name = row.name,
              s.category = row.category;

LOAD CSV WITH HEADERS FROM 'file:///companies.csv' AS row
MERGE (co:Company {id: row.id})
ON CREATE SET co.name = row.name,
              co.industry = row.industry;

LOAD CSV WITH HEADERS FROM 'file:///recruiters.csv' AS row
MERGE (r:Recruiter {id: row.id})
ON CREATE SET r.name = row.name,
              r.agency = row.agency;

LOAD CSV WITH HEADERS FROM 'file:///vacancies.csv' AS row
MERGE (v:Vacancy {id: row.id})
ON CREATE SET v.title = row.title,
              v.min_salary = toInteger(row.min_salary),
              v.max_salary = toInteger(row.max_salary),
              v.status = row.status;

LOAD CSV WITH HEADERS FROM 'file:///applications.csv' AS row
MERGE (a:Application {id: row.id})
ON CREATE SET a.applied_date = date(row.applied_date),
              a.status = row.status;

LOAD CSV WITH HEADERS FROM 'file:///interviews.csv' AS row
MERGE (i:Interview {id: row.id})
ON CREATE SET i.stage = row.stage,
              i.status = row.status,
              i.interview_date = date(row.interview_date);

              
LOAD CSV WITH HEADERS FROM 'file:///rel_has_skill.csv' AS row
MATCH (c:Candidate {id: row.candidate_id})
MATCH (s:Skill {id: row.skill_id})
MERGE (c)-[r:HAS_SKILL]->(s)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_requires_skill.csv' AS row
MATCH (v:Vacancy {id: row.vacancy_id})
MATCH (s:Skill {id: row.skill_id})
MERGE (v)-[r:REQUIRES_SKILL]->(s)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_submitted.csv' AS row
MATCH (c:Candidate {id: row.candidate_id})
MATCH (a:Application {id: row.app_id})
MERGE (c)-[r:SUBMITTED]->(a)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_for_vacancy.csv' AS row
MATCH (a:Application {id: row.app_id})
MATCH (v:Vacancy {id: row.vacancy_id})
MERGE (a)-[r:FOR_VACANCY]->(v)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_posted.csv' AS row
MATCH (co:Company {id: row.company_id})
MATCH (v:Vacancy {id: row.vacancy_id})
MERGE (co)-[r:POSTED]->(v)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_manages.csv' AS row
MATCH (rc:Recruiter {id: row.recruiter_id})
MATCH (v:Vacancy {id: row.vacancy_id})
MERGE (rc)-[r:MANAGES]->(v)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_has_stage.csv' AS row
MATCH (a:Application {id: row.app_id})
MATCH (i:Interview {id: row.interview_id})
MERGE (a)-[r:HAS_STAGE]->(i)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);

LOAD CSV WITH HEADERS FROM 'file:///rel_conducts.csv' AS row
MATCH (rc:Recruiter {id: row.recruiter_id})
MATCH (i:Interview {id: row.interview_id})
MERGE (rc)-[r:CONDUCTS]->(i)
ON CREATE SET r.source = row.source,
              r.confidence = toFloat(row.confidence),
              r.validFrom = date(row.validFrom);