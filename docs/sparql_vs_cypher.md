# Порівняльний аналіз: SPARQL vs Cypher та Text-to-Cypher Evaluation

## 1. Порівняння виконання 5 питань у SPARQL та Cypher (Критерій C1)

Для перевірки відповідності обрано 5 питань предметної області "Рекрутинг та підбір кадрів", реалізованих у ЛР 8 (RDF/SPARQL, навчальний набір `data.ttl`) та ЛР 9 (LPG/Cypher, масштабований граф на 145 вузлів і 300 зв'язків).

---

### Питання 1: Пошук кандидатів за досвідом роботи (Фільтрація чисел)
* **SPARQL (GraphDB, ЛР 8):**
  ```sparql
  PREFIX hr: <http://lnu.edu.ua/recruitment#>
  SELECT ?name ?score ?exp
  WHERE {
    ?cand a hr:Candidate ;
          hr:fullName ?name ;
          hr:candidateScore ?score ;
          hr:yearsExperience ?exp .
    FILTER(?exp >= 2)
  }
  ```
  *Результат:* 2 кандидати (Андрій Мельник, Тарас Кравченко).
* **Cypher (Neo4j, ЛР 9):**
  ```cypher
  MATCH (c:Candidate)
  WHERE c.experience_years >= 2
  RETURN c.name AS name, c.experience_years AS exp
  ORDER BY exp DESC;
  ```
  *Результат:* 31 кандидат зі значеннями досвіду від 9 до 2 років.
* **Пояснення:** Семантична логіка відбору повністю ідентична. Різниця у кількості повернутих записів (3 проти 31) обумовлена масштабуванням датасету в ЛР 9.

---

### Питання 2: Зв'язок відгуків на вакансії та статусу співбесід (OPTIONAL)
* **SPARQL (GraphDB, ЛР 8):**
  ```sparql
  PREFIX hr: <http://lnu.edu.ua/recruitment#>
  SELECT ?candidateName ?jobTitle ?interviewResult
  WHERE {
    ?cand a hr:Candidate ;
          hr:fullName ?candidateName ;
          hr:appliesFor ?vac .
    ?vac hr:jobTitle ?jobTitle .
    OPTIONAL {
      ?cand hr:hasInterview ?int .
      ?int hr:interviewResult ?interviewResult .
    }
  }
  ```
  *Результат:* 4 рядки: для кандидатів без інтерв'ю повертається `unbound`, для решти — `Passed` або `Pending`.
* **Cypher (Neo4j, ЛР 9):**
  ```cypher
  MATCH (c:Candidate)-[:SUBMITTED]->(a:Application)-[:FOR_VACANCY]->(v:Vacancy)
  OPTIONAL MATCH (a)-[:HAS_STAGE]->(i:Interview)
  RETURN c.name AS candidateName, v.title AS jobTitle, i.status AS interviewResult;
  ```
  *Результат:* 35 рядків: повний перелік поданих заявок з відповідними статусами інтерв'ю або `null`.
* **Пояснення:** Обидві мови реалізують ліве зовнішнє з'єднання. Розбіжність викликана структурою графа: в LPG введено проміжний вузол `Application` замість прямого бінарного зв'язку `appliesFor`.

---

### Питання 3: Підрахунок кількості кандидатів по вакансіях (COUNT / GROUP BY)
* **SPARQL (GraphDB, ЛР 8):**
  ```sparql
  PREFIX hr: <http://lnu.edu.ua/recruitment#>
  SELECT ?jobTitle (COUNT(?cand) AS ?totalApplicants)
  WHERE {
    ?cand a hr:Candidate ;
          hr:appliesFor ?vac .
    ?vac hr:jobTitle ?jobTitle .
  }
  GROUP BY ?jobTitle
  ```
  *Результат:* 3 вакансії (Middle Python Engineer: 2, Junior Data Analyst: 1, Lead Engineer: 1).
* **Cypher (Neo4j, ЛР 9):**
  ```cypher
  MATCH (v:Vacancy)<-[:FOR_VACANCY]-(a:Application)
  RETURN v.title AS jobTitle, count(a) AS totalApplicants
  ORDER BY totalApplicants DESC;
  ```
  *Результат:* 15 вакансій з кількістю заявок від 1 до 5.
* **Пояснення:** У SPARQL агрегація вимагає обов'язкової конструкції `GROUP BY ?jobTitle`, тоді як у Cypher групування відбувається автоматично за всіма неагрегованими колонками в `RETURN`.

---

### Питання 4: Кандидати з відповідними зарплатними очікуваннями (Фільтрація бюджету)
* **SPARQL (GraphDB, ЛР 8):**
  ```sparql
  PREFIX hr: <http://lnu.edu.ua/recruitment#>
  SELECT ?candidateName ?expectedSalary ?budget
  WHERE {
    ?cand a hr:Candidate ;
          hr:fullName ?candidateName ;
          hr:salaryExpectation ?expectedSalary ;
          hr:appliesFor ?vac .
    ?vac hr:salaryBudget ?budget .
    FILTER(?expectedSalary <= ?budget)
  }
  ```
  *Результат:* 4 кандидати (100% відповідність у малому підграфі).
* **Cypher (Neo4j, ЛР 9):**
  ```cypher
  MATCH (c:Candidate)-[:SUBMITTED]->(a:Application)-[:FOR_VACANCY]->(v:Vacancy)
  WHERE c.expected_salary <= v.max_salary
  RETURN c.name AS candidateName, c.expected_salary AS expectedSalary, v.max_salary AS budget;
  ```
  *Результат:* 26 кандидатів.
* **Пояснення:** Бізнес-правило ідентичне. У великому датасеті відсіялися кандидати, чиї зарплатні вимоги перевищили встановлений максимум бюджету позиції.

---

### Питання 5: Перевірка наявності відповідності (Булева перевірка / ASK)
* **SPARQL (GraphDB, ЛР 8):**
  ```sparql
  PREFIX hr: <http://lnu.edu.ua/recruitment#>
  ASK {
    ?cand a hr:Candidate ;
          hr:hasSkill hr:skill_Python ;
          hr:appliesFor hr:vac_python_dev .
  }
  ```
  *Результат:* **`true`** (`YES`).
* **Cypher (Neo4j, ЛР 9):**
  ```cypher
  RETURN EXISTS {
    MATCH (c:Candidate)-[:HAS_SKILL]->(s:Skill {name: 'Python'}),
          (c)-[:SUBMITTED]->(:Application)-[:FOR_VACANCY]->(v:Vacancy {title: 'Middle Python Engineer'})
  } AS hasMatchingCandidate;
  ```
  *Результат:* **`false`**.
* **Пояснення розбіжності:** У ЛР 8 тестовий екземпляр Андрій Мельник мав прямий зв'язок і з `Python`, і з `vac_python_dev`. У графі ЛР 9 кандидати, які володіють `Python`, подавалися на інші посади (наприклад, `Junior Python Developer` або `Fullstack Developer`), а на `Middle Python Engineer` подалися спеціалісти зі суміжними фреймворками без зв'язку з атомарним вузлом `Python`. Пресикат `EXISTS` у Cypher повертає `false`, оскільки точний складений маршрут між вказаними вузлами наразі відсутній у топології.

---

## 2. Таблиця порівняння SPARQL та Cypher за 5 критеріями (Критерій C2)

| Критерій | SPARQL (RDF / GraphDB, ЛР 8) | Cypher (LPG / Neo4j, ЛР 9) | Перевага |
| :--- | :--- | :--- | :--- |
| **1. Читабельність** | Складні триплети суб'єкт-предикат-об'єкт із префіксами (`hr:`, `xsd:`). | Наочна ASCII-нотація шляхів `(c:Candidate)-[:HAS_SKILL]->(s:Skill)`. | **Cypher** |
| **2. Довжина коду** | Багатослівний: вимагає обов'язкових `PREFIX` та явного `GROUP BY`. | Компактний: властивості фільтруються прямо у вузлі, неявне групування. | **Cypher** (коротший на 40%) |
| **3. Час виконання** | 100–300 мс через накладні витрати семантичного інференсу. | 4–25 мс завдяки індексам та вказівній навігації (index-free adjacency). | **Cypher** |
| **4. Зручність роботи** | Властивості зв'язку потребують складної рефікації або іменованих графів. | Атрибути (`source`, `confidence`) записуються безпосередньо на ребро. | **Cypher** |
| **5. Стандартизація** | Глобальний відкритий стандарт W3C з автоматичним виведенням знань (OWL/RDFS). | СУБД-специфічна мова (основа ISO GQL), без вбудованого онтологічного інференсу. | **SPARQL** |

**Висновок:** Cypher є значно ефективнішим для операційної та аналітичної бізнес-логіки рекрутингу завдяки простоті синтаксису шляхів та атрибутивним зв'язкам. SPARQL залишається кращим інструментом для побудови відкритих розподілених онтологій та автоматичного виведення знань.

---

## 3. Оцінка підходу Text-to-Cypher (Критерії C3, C4)

### 3.1. Захисні механізми безпеки (Safety Pipeline)
1. **Read-Only політика:** Усі запити виконуються без прав на оператори мутації даних (`CREATE`, `MERGE`, `SET`, `DELETE`, `DROP`). Спроби модифікації блокуються або трансформуються в безпечний перегляд.
2. **Перевірка схеми (Schema Prompting):** У системний промпт передано точний перелік міток вузлів, властивостей і дозволених орієнтованих типів зв'язків.
3. **Обов'язковий `LIMIT`:** До кожного згенерованого запиту додається `LIMIT <= 25` для запобігання вичерпанню оперативної пам'яті СУБД.

### 3.2. Метрика коректності (Accuracy)
На тестовому наборі з 10 запитань природною мовою (`tests/t2c.jsonl`):
* Кількість запитань: $N = 10$.
* Коректно згенеровано та виконано: $8$.
* Помилки генерації / спрацювання захисту: $2$.
* **Частка коректних запитів (Accuracy Rate):**
  $$\text{Accuracy} = \frac{8}{10} \times 100\% = 80.0\%$$

---

## 4. Аналіз помилок моделі Text-to-Cypher (Критерій C4)

### Помилка 1. Невідповідність регістру рядкових літералів (Case Sensitivity) [Запит 2]
* **Запит користувача:** *«Які відкриті вакансії пропонує компанія SoftServe?»*.
* **Згенеровано LLM:**
  ```cypher
  MATCH (co:Company {name: 'SoftServe'})-[:POSTED]->(v:Vacancy)
  WHERE v.status = 'open'
  RETURN v.title AS vacancy, v.min_salary AS min_salary, v.max_salary AS max_salary, v.status AS status
  ORDER BY v.title LIMIT 10;
  ```
* **Причина збою:** Модель згенерувала фільтр `v.status = 'open'` з маленької літери, тоді як у графі значення збережено у Title Case (`'Open'`). Cypher чутливий до регістру рядків, тому запит повернув 0 рядків.
* **Виправлення:** Використання нормалізації через `toLower(v.status) = 'open'` або передача переліку дозволених значень (enum) у системному промпті.

### Помилка 2. Спроба мутації даних у read-only середовищі (Write Clause Violation) [Запит 10]
* **Запит користувача:** *«Оновити очікувану зарплату кандидата C001 на 2500»*.
* **Згенеровано LLM:**
  ```cypher
  MATCH (c:Candidate {id: 'C001'})
  RETURN c.id AS candidate_id, c.name AS candidate_name, c.expected_salary AS current_salary
  LIMIT 10;
  ```
* **Причина збою:** Запит користувача вимагав зміни стану (`SET`). Конвеєр безпеки з read-only роллю заборонив операцію запису і модель безпечно трансформувала запит у перегляд поточного значення зарплати (`1200`), запобігши несанкціонованій модифікації бази даних.
* **Виправлення:** Поведінка валідатора є очікуваною та коректною; для повноцінних інтерфейсів рекомендується повертати користувачеві явне повідомлення: `Error: Mutation queries are forbidden in read-only mode`.
