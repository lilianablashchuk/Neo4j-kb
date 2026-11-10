# Відображення Компетентнісних Питань (CQ) та Схеми LPG на Онтологію

## 1. Склад схеми графа (Labeled Property Graph)

### Вузли (7 міток / Labels) та їхні властивості:
1. `:Candidate` — `id: String`, `name: String`, `experience_years: Int`, `expected_salary: Int`, `city: String`
2. `:Skill` — `id: String`, `name: String`, `category: String`
3. `:Vacancy` — `id: String`, `title: String`, `min_salary: Int`, `max_salary: Int`, `status: String`
4. `:Application` — `id: String`, `applied_date: Date`, `status: String`
5. `:Interview` — `id: String`, `stage: String`, `status: String`, `interview_date: Date`
6. `:Company` — `id: String`, `name: String`, `industry: String`
7. `:Recruiter` — `id: String`, `name: String`, `agency: String`

### Зв'язки (8 типів / Relationships):
1. `(:Candidate)-[:HAS_SKILL]->(:Skill)`
2. `(:Vacancy)-[:REQUIRES_SKILL]->(:Skill)`
3. `(:Candidate)-[:SUBMITTED]->(:Application)`
4. `(:Application)-[:FOR_VACANCY]->(:Vacancy)`
5. `(:Company)-[:POSTED]->(:Vacancy)`
6. `(:Recruiter)-[:MANAGES]->(:Vacancy)`
7. `(:Application)-[:HAS_STAGE]->(:Interview)`
8. `(:Recruiter)-[:CONDUCTS]->(:Interview)`


## 2. Метадані походження (Provenance) на зв'язках (Критерій C3)

Для оцінки достовірності знань кожен зв'язок у LPG містить атрибути походження:
* `source: String` — джерело походження факту (`'CV_parsing'`, `'HR_spec'`, `'Djinni'`, `'System'`, `'Portal'`, `'Assignment'`, `'ATS_event'`, `'Calendar'`).
* `confidence: Float` — рівень достовірності від 0.0 до 1.0 (для екстракції з резюме $\approx 0.95$, для прямих системних подій $= 1.0$).
* `validFrom: Date` — часова позначка набуття чинності факту (наприклад, `date('2026-10-15')`).


## 3. Відображення Компетентнісних Питань (CQ) на шаблони Cypher (Критерій C2)

| № | Компетентнісне питання (CQ) | Шаблон Cypher-шляху | Опис відповідності |
|---|---|---|---|
| **CQ1** | Які кандидати володіють навичками, що вимагаються для певної вакансії? | `(c:Candidate)-[:HAS_SKILL]->(s:Skill)<-[:REQUIRES_SKILL]-(v:Vacancy)` | Прямий матчинг кандидата та вакансії через спільний вузол навички. |
| **CQ2** | Які кандидати подали заявки на вакансії конкретної компанії? | `(c:Candidate)-[:SUBMITTED]->(:Application)-[:FOR_VACANCY]->(:Vacancy)<-[:POSTED]-(co:Company)` | Проходження через сутність заявки до вакансії роботодавця. |
| **CQ3** | Які навички найбільш затребувані у вакансіях певної компанії? | `(co:Company)-[:POSTED]->(v:Vacancy)-[:REQUIRES_SKILL]->(s:Skill)` | Агрегація навичок, що вимагаються через опубліковані вакансії. |
| **CQ4** | Які рекрутери курують вакансії, на які кандидат подав заявку? | `(c:Candidate)-[:SUBMITTED]->(:Application)-[:FOR_VACANCY]->(v:Vacancy)<-[:MANAGES]-(r:Recruiter)` | Виявлення відповідального рекрутера для кандидата через заявку та вакансію. |
| **CQ5** | Які етапи співбесід та з яким статусом призначені для заявки кандидата? | `(c:Candidate)-[:SUBMITTED]->(a:Application)-[:HAS_STAGE]->(i:Interview)` | Моніторинг проходження етапів відбору (Screening, Tech, HR) конкретного кандидата. |
| **CQ6** | Які спільні компетенції мають між собою два кандидати? | `(c1:Candidate)-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(c2:Candidate)` | Пошук взаємного перетину навичок двох кандидатів. |
| **CQ7** | Які співбесіди проводить закріплений за вакансією рекрутер? | `(r:Recruiter)-[:CONDUCTS]->(i:Interview)<-[:HAS_STAGE]-(:Application)-[:FOR_VACANCY]->(v:Vacancy)<-[:MANAGES]-(r)` | Валідація завантаженості рекрутера на інтерв'ю в межах його вакансій. |
| **CQ8** | Які кандидати пройшли співбесіду на вакансію, маючи відповідний зарплатний діапазон? | `(c:Candidate)-[:SUBMITTED]->(a:Application {status: 'In_Progress'})-[:FOR_VACANCY]->(v:Vacancy)` і `(a)-[:HAS_STAGE]->(i:Interview {status: 'Passed'})` | Фільтрація претендентів за прогресом інтерв'ю та числовими критеріями (`c.expected_salary <= v.max_salary`). |


## 4. Порівняння зі схемою онтології ЛР 7 (Критерій C4)

| Концепт предметної області | Концепт онтології (OWL / RDF, ЛР 7) | Елемент у Neo4j (LPG, ЛР 9) | Тип трансформації | Обґрунтування в LPG |
|---|---|---|---|---|
| Кандидат | `owl:Class :Candidate` | Мітка вузла `:Candidate` | Клас $\rightarrow$ Label | Швидка індексація за міткою без накладних витрат семантичного інференсу. |
| Навичка | `owl:Class :Skill` | Мітка вузла `:Skill` | Клас $\rightarrow$ Label | Вузол навички стає точкою перетину запитів матчингу. |
| Вакансія | `owl:Class :Vacancy` | Мітка вузла `:Vacancy` | Клас $\rightarrow$ Label | Центральна сутність пайплайну найму. |
| Заявка на вакансію | `owl:Class :JobApplication` | Мітка вузла `:Application` | Клас $\rightarrow$ Label | Вузол замінює n-арний семантичний зв'язок між кандидатом, статусом та вакансією. |
| Інтерв'ю / Співбесіда | `owl:Class :InterviewEvent` | Мітка вузла `:Interview` | Клас $\rightarrow$ Label | Дозволяє зберігати дату та статус окремого етапу пайплайну. |
| Компанія | `owl:Class :Company` | Мітка вузла `:Company` | Клас $\rightarrow$ Label | Роботодавець, який володіє пулом вакансій. |
| Рекрутер | `owl:Class :Recruiter` | Мітка вузла `:Recruiter` | Клас $\rightarrow$ Label | Відповідальна особа за вакансії та проведення інтерв'ю. |
| Володіння навичкою | `owl:ObjectProperty :hasSkill` | Зв'язок `[:HAS_SKILL]` | ObjectProperty $\rightarrow$ Relationship | В LPG на ребро напряму додаються атрибути походження (`source`, `confidence`), що в RDF вимагало б рефікації (RDF-star / Named Graphs). |
| Вимога вакансії | `owl:ObjectProperty :requiresSkill` | Зв'язок `[:REQUIRES_SKILL]` | ObjectProperty $\rightarrow$ Relationship | Пряме орієнтоване ребро для оптимізованого графового обходу. |
| Досвід роботи | `owl:DatatypeProperty :experienceYears` | Властивість `experience_years: Int` | DatatypeProperty $\rightarrow$ Node Property | Збереження у вузлі як базовий скалярний тип для швидкої фільтрації в `WHERE`. |
| Очікувана зарплата | `owl:DatatypeProperty :expectedSalary` | Властивість `expected_salary: Int` | DatatypeProperty $\rightarrow$ Node Property | Числове поле для побудови фільтрів діапазонів без конвертації рядкових літералів. |