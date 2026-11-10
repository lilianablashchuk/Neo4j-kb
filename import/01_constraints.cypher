// 1. Унікальні обмеження (Constraints)
CREATE CONSTRAINT candidate_id_unique IF NOT EXISTS
FOR (c:Candidate) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT vacancy_id_unique IF NOT EXISTS
FOR (v:Vacancy) REQUIRE v.id IS UNIQUE;

CREATE CONSTRAINT skill_id_unique IF NOT EXISTS
FOR (s:Skill) REQUIRE s.id IS UNIQUE;

// 2. Індекси (Indexes)
CREATE INDEX candidate_name_idx IF NOT EXISTS
FOR (c:Candidate) ON (c.name);

CREATE INDEX skill_name_idx IF NOT EXISTS
FOR (s:Skill) ON (s.name);

CREATE INDEX vacancy_title_idx IF NOT EXISTS
FOR (v:Vacancy) ON (v.title);