import pandas as pd
import random
import os

random.seed(42)
os.makedirs("data", exist_ok=True)

# 1. Вузли: Candidates (35)
names = [
    "Олександр Коваль", "Анна Шевченко", "Максим Бондаренко", "Юлія Ткаченко",
    "Дмитро Кравченко", "Олена Олійник", "Богдан Мороз", "Ірина Козак",
    "Сергій Павленко", "Вікторія Савченко", "Тарас Василенко", "Наталія Марченко",
    "Андрій Руденко", "Оксана Лисенко", "Роман Білинський", "Христина Мельник",
    "Ярослав Дубовик", "Софія Воробей", "Василь Горобець", "Марія Сидоренко",
    "Ігор Семенов", "Тетяна Поліщук", "Денис Гриценко", "Катерина Білоус",
    "Віталій Романюк", "Анастасія Демченко", "Юрій Степаненко", "Ольга Кириленко",
    "Артем Кузьменко", "Дарина Панченко", "Михайло Мазур", "Аліна Дорошенко",
    "Владислав Федоренко", "Поліна Литвин", "Євген Колісник"
]
cities = ["Львів", "Київ", "Дніпро", "Одеса", "Харків", "Варшава"]
candidates = [{
    "id": f"C{i:03d}", "name": name,
    "experience_years": random.randint(1, 10),
    "expected_salary": random.choice([1200, 1800, 2500, 3200, 4000, 5000]),
    "city": random.choice(cities)
} for i, name in enumerate(names, 1)]
pd.DataFrame(candidates).to_csv("data/candidates.csv", index=False)

# Вузли: Skills (25)
skills = [
    ("SK001", "Python", "Programming"), ("SK002", "JavaScript", "Programming"),
    ("SK003", "TypeScript", "Programming"), ("SK004", "Java", "Programming"),
    ("SK005", "C++", "Programming"), ("SK006", "Go", "Programming"),
    ("SK007", "FastAPI", "Framework"), ("SK008", "Django", "Framework"),
    ("SK009", "React", "Framework"), ("SK010", "Vue.js", "Framework"),
    ("SK011", "Node.js", "Framework"), ("SK012", "Spring Boot", "Framework"),
    ("SK013", "PostgreSQL", "Database"), ("SK014", "Neo4j", "Database"),
    ("SK015", "Redis", "Database"), ("SK016", "Docker", "DevOps"),
    ("SK017", "Kubernetes", "DevOps"), ("SK018", "CI/CD", "DevOps"),
    ("SK019", "AWS", "Cloud"), ("SK020", "GCP", "Cloud"),
    ("SK021", "Git", "Tool"), ("SK022", "Scikit-Learn", "Data Science"),
    ("SK023", "PyTorch", "Data Science"), ("SK024", "Scrum", "Methodology"),
    ("SK025", "Communication", "Soft Skill")
]
pd.DataFrame([{"id": s[0], "name": s[1], "category": s[2]} for s in skills]).to_csv("data/skills.csv", index=False)

# Вузли: Companies (10)
companies = [
    ("CO001", "SoftServe", "IT Consulting"), ("CO002", "EPAM Systems", "Software Engineering"),
    ("CO003", "GlobalLogic", "Product Engineering"), ("CO004", "Grammarly", "AI & NLP"),
    ("CO005", "MacPaw", "macOS Software"), ("CO006", "Genesis", "Venture Builder"),
    ("CO007", "N-iX", "Software Development"), ("CO008", "Ciklum", "Digital Solutions"),
    ("CO009", "Intellias", "Mobility & FinTech"), ("CO010", "Sigma Software", "Custom Development")
]
pd.DataFrame([{"id": c[0], "name": c[1], "industry": c[2]} for c in companies]).to_csv("data/companies.csv", index=False)

# Вузли: Recruiters (10)
recruiters = [
    ("R001", "Ілона Гончар", "SoftServe Talent"), ("R002", "Маркіян Сенів", "EPAM Hiring"),
    ("R003", "Соломія Ковальчук", "TechRecruit UA"), ("R004", "Олена Войтко", "Grammarly HR"),
    ("R005", "Ярослава Дзюба", "MacPaw People"), ("R006", "Віктор Мельничук", "Genesis Stars"),
    ("R007", "Богдана Хома", "N-iX Careers"), ("R008", "Андрій Луцький", "Ciklum Global"),
    ("R009", "Марта Присяжнюк", "Intellias People"), ("R010", "Данило Савка", "Sigma Recruits")
]
pd.DataFrame([{"id": r[0], "name": r[1], "agency": r[2]} for r in recruiters]).to_csv("data/recruiters.csv", index=False)

# Вузли: Vacancies (20)
roles = ["Junior Python Developer", "Middle Python Engineer", "Senior Backend Architect",
         "Frontend React Engineer", "Fullstack Developer (Node/React)", "Lead DevOps Engineer",
         "Junior Data Scientist", "Senior ML Engineer", "QA Automation Engineer", "Product Manager"]
vacancies = [{
    "id": f"V{i:03d}", "title": roles[(i - 1) % len(roles)],
    "min_salary": (min_s := random.choice([1000, 1500, 2000, 3000, 4000])),
    "max_salary": min_s + random.choice([800, 1200, 1500]),
    "status": random.choice(["Open", "Open", "Open", "Interviewing", "Closed"])
} for i in range(1, 21)]
pd.DataFrame(vacancies).to_csv("data/vacancies.csv", index=False)

# Вузли: Applications (25)
apps = [{"id": f"APP{i:03d}", "applied_date": f"2026-10-{random.randint(1, 28):02d}",
         "status": random.choice(["New", "Screening", "In_Progress", "Offered", "Rejected"])} for i in range(1, 26)]
pd.DataFrame(apps).to_csv("data/applications.csv", index=False)

# Вузли: Interviews (20)
interviews = [{"id": f"INT{i:03d}", "stage": random.choice(["Screening", "Tech_Interview", "Live_Coding", "HR_Final"]),
               "status": random.choice(["Passed", "Passed", "Failed", "Scheduled"]),
               "interview_date": f"2026-11-{random.randint(1, 10):02d}"} for i in range(1, 21)]
pd.DataFrame(interviews).to_csv("data/interviews.csv", index=False)

# Зв'язки
# 1. HAS_SKILL
has_skills = [{"candidate_id": c["id"], "skill_id": s[0], "source": "CV_parsing",
               "confidence": round(random.uniform(0.85, 0.99), 2), "validFrom": "2026-09-01"}
              for c in candidates for s in random.sample(skills, k=random.randint(2, 4))]
pd.DataFrame(has_skills).to_csv("data/rel_has_skill.csv", index=False)

# 2. REQUIRES_SKILL
req_skills = [{"vacancy_id": v["id"], "skill_id": s[0], "source": "HR_spec",
               "confidence": 1.0, "validFrom": "2026-10-01"}
              for v in vacancies for s in random.sample(skills, k=random.randint(2, 4))]
pd.DataFrame(req_skills).to_csv("data/rel_requires_skill.csv", index=False)

# 3. SUBMITTED
pd.DataFrame([{"candidate_id": candidates[i]["id"], "app_id": apps[i]["id"],
               "source": "Djinni", "confidence": 1.0, "validFrom": apps[i]["applied_date"]}
              for i in range(25)]).to_csv("data/rel_submitted.csv", index=False)

# 4. FOR_VACANCY
pd.DataFrame([{"app_id": apps[i]["id"], "vacancy_id": vacancies[i % len(vacancies)]["id"],
               "source": "System", "confidence": 1.0, "validFrom": apps[i]["applied_date"]}
              for i in range(25)]).to_csv("data/rel_for_vacancy.csv", index=False)

# 5. POSTED
pd.DataFrame([{"company_id": companies[i % len(companies)][0], "vacancy_id": vacancies[i]["id"],
               "source": "Portal", "confidence": 1.0, "validFrom": "2026-09-15"}
              for i in range(20)]).to_csv("data/rel_posted.csv", index=False)

# 6. MANAGES
pd.DataFrame([{"recruiter_id": recruiters[i % len(recruiters)][0], "vacancy_id": vacancies[i]["id"],
               "source": "Assignment", "confidence": 1.0, "validFrom": "2026-09-20"}
              for i in range(20)]).to_csv("data/rel_manages.csv", index=False)

# 7. HAS_STAGE
pd.DataFrame([{"app_id": apps[i]["id"], "interview_id": interviews[i]["id"],
               "source": "ATS_event", "confidence": 1.0, "validFrom": interviews[i]["interview_date"]}
              for i in range(20)]).to_csv("data/rel_has_stage.csv", index=False)

# 8. CONDUCTS
pd.DataFrame([{"recruiter_id": recruiters[i % len(recruiters)][0], "interview_id": interviews[i]["id"],
               "source": "Calendar", "confidence": 1.0, "validFrom": interviews[i]["interview_date"]}
              for i in range(20)]).to_csv("data/rel_conducts.csv", index=False)

print("Дані успішно згенеровано в папку data/!")