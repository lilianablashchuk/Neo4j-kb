# Результати виконання запитів Cypher та Аналіз впливу

## 1. Базові компетентнісні запити (CQ1 – CQ8)

### CQ1: Підбір кандидатів за навичками та зарплатним лімітом
* **Питання:** Які кандидати володіють навичками під вакансію `V001` та вписуються у бюджет?
* **Конструкції Cypher:** `MATCH`, `WHERE`, `collect()`, `size()`, `ORDER BY`.
```cypher
MATCH (v:Vacancy {id: 'V001'})-[:REQUIRES_SKILL]->(s:Skill)<-[:HAS_SKILL]-(c:Candidate)
WHERE c.expected_salary <= v.max_salary
RETURN v.title AS Vacancy, 
       c.name AS Candidate, 
       c.expected_salary AS Salary, 
       collect(s.name) AS MatchedSkills
ORDER BY size(MatchedSkills) DESC, Candidate ASC;
```
* **Результат:**
  - `Дмитро Кравченко` | 1200 | `['JavaScript']`
  - `Юлія Ткаченко` | 1200 | `['JavaScript']`
  - `Ірина Козак` | 1800 | `['Django']`
* **Інтерпретація:** Запит виконує автоматичний прескринінг пулу шукачів за сумісністю стеку та граничним бюджетом посади.

---

### CQ2: Статистика поданих заявок по компаніях
* **Питання:** Скільки заявок отримала кожна компанія та хто з кандидатів їх подав?
* **Конструкції Cypher:** `WITH`, `count()`, `collect(DISTINCT)`.
```cypher
MATCH (co:Company)-[:POSTED]->(v:Vacancy)<-[:FOR_VACANCY]-(a:Application)<-[:SUBMITTED]-(c:Candidate)
WITH co.name AS Company, count(a) AS ApplicationsCount, collect(DISTINCT c.name) AS Applicants
RETURN Company, ApplicationsCount, Applicants
ORDER BY ApplicationsCount DESC;
```
* **Результат:** Згрупований перелік компаній (SoftServe, EPAM, Grammarly тощо) із лічильником вхідних відгуків.
* **Інтерпретація:** Визначає роботодавців із найбільшою привабливістю та навантаженням на первинну лінію обробки резюме.

---

### CQ3: Вакансії та вимоги до компетенцій (із підтримкою неповних даних)
* **Питання:** Які відкриті позиції має компанія `SoftServe` та які навички потрібні?
* **Конструкції Cypher:** `OPTIONAL MATCH`, `coalesce()`.
```cypher
MATCH (co:Company {name: 'SoftServe'})-[:POSTED]->(v:Vacancy)
OPTIONAL MATCH (v)-[:REQUIRES_SKILL]->(s:Skill)
RETURN v.title AS Vacancy, v.status AS Status, coalesce(collect(s.name), []) AS SkillsRequired;
```
* **Результат:** Список позицій компанії з масивами технологій навіть за відсутності заповнених вимог.
* **Інтерпретація:** Використання `OPTIONAL MATCH` унеможливлює втрату вакансій, стек яких ще узгоджується із замовником.

---

### CQ4: Моніторинг завантаженості рекрутерів
* **Питання:** Скільки відкритих вакансій і активних кандидатів курує кожен рекрутер?
* **Конструкції Cypher:** `OPTIONAL MATCH`, фільтр у патерні, `count(DISTINCT)`.
```cypher
MATCH (r:Recruiter)-[:MANAGES]->(v:Vacancy {status: 'Open'})
OPTIONAL MATCH (v)<-[:FOR_VACANCY]-(a:Application)
RETURN r.name AS Recruiter, 
       r.agency AS Agency, 
       count(DISTINCT v) AS OpenVacancies, 
       count(a) AS ActiveApplications
ORDER BY ActiveApplications DESC;
```
* **Результат:** Таблиця розподілу проектів між спеціалістами агентства.
* **Інтерпретація:** Допомагає оптимізувати розподіл робочого навантаження та запобігає «пляшковим горлам» у комунікації.

---

### CQ5: Моніторинг успішності проходження інтерв'ю
* **Питання:** Хто з кандидатів успішно пройшов призначені етапи оцінки?
* **Конструкції Cypher:** фільтрація за скаляром `WHERE i.status = 'Passed'`.
```cypher
MATCH (c:Candidate)-[:SUBMITTED]->(a:Application)-[:HAS_STAGE]->(i:Interview)
WHERE i.status = 'Passed'
RETURN c.name AS Candidate, a.id AS Application, i.stage AS Stage, i.interview_date AS Date
ORDER BY i.interview_date DESC;
```
* **Результат:** Список претендентів, рекомендованих до наступних раундів відбору.
* **Інтерпретація:** Забезпечує контроль воронки та готовність кандидатів до формування фінального оферу.

---

### CQ6: Пошук схожих профілів за графовим шляхом
* **Питання:** Які спеціалісти мають схожий технологічний профіль із кандидатом `C001`?
* **Конструкції Cypher:** шлях змінної довжини `[:HAS_SKILL*2]`, виключення себе `c1 <> c2`.
```cypher
MATCH (c1:Candidate {id: 'C001'})-[:HAS_SKILL*2]-(c2:Candidate)
WHERE c1 <> c2
RETURN c1.name AS BaseCandidate, c2.name AS SimilarCandidate, count(*) AS CommonSkillsCount
ORDER BY CommonSkillsCount DESC
LIMIT 5;
```
* **Результат:** Топ-5 кандидатів із найбільшою кількістю спільних стеків.
* **Інтерпретація:** Реалізує внутрішній алгоритм колаборативної рекомендації резервних кандидатів.

---

### CQ7: Найкоротший шлях взаємодії
* **Питання:** Який найкоротший шлях пов'язує кандидата `C001` із представником рекрутингу?
* **Конструкції Cypher:** `shortestPath()`, `length()`, `nodes()`.
```cypher
MATCH (c:Candidate {id: 'C001'}), (r:Recruiter)
MATCH p = shortestPath((c)-[*]-(r))
RETURN r.name AS Recruiter, 
       length(p) AS PathDistance, 
       [n IN nodes(p) | coalesce(n.name, n.title, n.id)] AS PathNodes
LIMIT 1;
```
* **Результат:** Відстань `3`, вузли: `['Олександр Коваль', 'APP001', 'Junior Python Developer', 'Ілона Гончар']`.
* **Інтерпретація:** Демонструє найшвидший маршрут ескалації та зв'язку в організаційному графі.

---

### CQ8: Глибокий параметричний фільтр за досвідом та фінансами
* **Питання:** Хто з кандидатів з досвідом $\ge 3$ років відповідає діапазону оплати вакансії?
* **Конструкції Cypher:** багаторівневий логічний `WHERE`.
```cypher
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
```
* **Результат:** Точні збіги кандидатів рівня Middle/Senior без ризику фінансового дискомфорту.
* **Інтерпретація:** Мінімізує відсоток відмов на етапі узгодження компенсаційного пакету.

---

## 2. Запити аналізу впливу (Impact Analysis, глибина $\ge 3$)

### Запит впливу 1: Каскадні наслідки вилучення навички зі стеку (глибина 3)
* **Сценарій:** Проєкт закриває напрям фреймворку `FastAPI`. Які відкриті вакансії, подані заявки та заплановані співбесіди зазнають змін?
```cypher
MATCH path = (s:Skill {name: 'FastAPI'})<-[:REQUIRES_SKILL]-(v:Vacancy)<-[:FOR_VACANCY]-(a:Application)-[:HAS_STAGE]->(i:Interview)
RETURN s.name AS DeprecatedSkill, 
       v.title AS AffectedVacancy, 
       a.id AS ImpactedApplication, 
       i.stage AS ScheduledStage, 
       i.status AS InterviewStatus,
       length(path) AS Depth;
```
* **Інтерпретація:** Показує каскадну залежність: коригування вимог до технології на глибині 3 рівнів вимагає скасування або зміни фокусу запланованих технічних інтерв'ю.

### Запит впливу 2: Оцінка виходу кандидата з процесу відбору (глибина 1..4)
* **Сценарій:** Кандидат `C001` знімає свою кандидатуру. Кого зі стейкхолдерів (рекрутери, роботодавці) це зачіпає?
```cypher
MATCH path = (c:Candidate {id: 'C001'})-[*1..4]-(target)
WHERE target:Recruiter OR target:Company
RETURN c.name AS Candidate, 
       labels(target)[0] AS StakeholderType, 
       target.name AS StakeholderName, 
       length(path) AS ImpactHops
ORDER BY ImpactHops ASC;
```
* **Інтерпретація:** Ідентифікує відповідальних осіб у радіусі до 4 хопів, яким необхідно надіслати автоматичне сповіщення про зміну статусу кандидата.

---

## 3. Ручна перевірка на малому підграфі (Критерій C4)

1. **CQ1 (Матчинг навичок для `V001`):** 
   - За вихідним файлом `rel_requires_skill.csv` вакансія `V001` потребує навичку `SK002` (JavaScript).
   - За файлом `candidates.csv` кандидат `C005` (Дмитро Кравченко) має зарплату `1200`, що менше за бюджет вакансії `2800`.
   - За файлом `rel_has_skill.csv` кандидат володіє `SK002`.
   - *Висновок:* Графовий запит правильно включив Дмитра Кравченка у відповідь.
2. **CQ5 (Успішне інтерв'ю):** 
   - Трасування: `candidates.csv` (`C001`) $\rightarrow$ `rel_submitted.csv` (`APP001`) $\rightarrow$ `rel_has_stage.csv` $\rightarrow$ `interviews.csv` (`INT001`, `HR_Final`, `Passed`).
   - *Висновок:* Запит Cypher безпомилково видав картку кандидата `Олександр Коваль` для етапу `HR_Final`.
3. **CQ7 (Найкоротший шлях до рекрутера):** 
   - Ланцюг: `Олександр Коваль` $\rightarrow$ `APP001` $\rightarrow$ `V001` $\rightarrow$ `R001` (Ілона Гончар) має довжину рівно 3 ребра.
   - *Висновок:* Алгоритм `shortestPath` вивів ідентичний склад вузлів і довжину 3.