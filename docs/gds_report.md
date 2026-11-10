# Результати аналізу графа (GDS) та оптимізації продуктивності

## 1. Запуск алгоритмів GDS (Критерій C1)

### 1.1. Проєкція графа в пам'ять (gds.graph.project)
```cypher
CALL gds.graph.project(
  'recruitmentGraph',
  ['Candidate', 'Skill', 'Vacancy', 'Company', 'Recruiter', 'Application', 'Interview'],
  {
    HAS_SKILL: {type: 'HAS_SKILL', orientation: 'UNDIRECTED'},
    REQUIRES_SKILL: {type: 'REQUIRES_SKILL', orientation: 'UNDIRECTED'},
    SUBMITTED: {type: 'SUBMITTED', orientation: 'UNDIRECTED'},
    FOR_VACANCY: {type: 'FOR_VACANCY', orientation: 'UNDIRECTED'},
    POSTED: {type: 'POSTED', orientation: 'UNDIRECTED'},
    MANAGES: {type: 'MANAGES', orientation: 'UNDIRECTED'},
    HAS_STAGE: {type: 'HAS_STAGE', orientation: 'UNDIRECTED'},
    CONDUCTS: {type: 'CONDUCTS', orientation: 'UNDIRECTED'}
  }
);
```

### 1.2. Результати PageRank (Топ-10 найважливіших вузлів)
| Позиція | Тип вузла | Назва сутності | PageRank Score |
| :--- | :--- | :--- | :--- |
| 1 | Skill | Django | 2.2002 |
| 2 | Skill | TypeScript | 2.1776 |
| 3 | Skill | Neo4j | 2.0876 |
| 4 | Skill | React | 1.9793 |
| 5 | Skill | Vue.js | 1.6526 |
| 6 | Skill | CI/CD | 1.6437 |
| 7 | Vacancy | Senior Backend Architect | 1.6118 |
| 8 | Vacancy | Fullstack Developer (Node/React) | 1.5671 |
| 9 | Vacancy | Middle Python Engineer | 1.5406 |
| 10 | Vacancy | Fullstack Developer (Node/React) | 1.5100 |

### 1.3. Результати Louvain (Виявлення спільнот)
Алгоритм успішно виявив понад 7 модулярних спільнот (умова $\ge 3$ виконана):
* **Спільнота 88 (21 вузол):** C++, Redis, низькорівнева розробка (Сергій Павленко, Софія Воробей).
* **Спільнота 93 (17 вузлів):** Загальний веброзробницький пул (Олександр Коваль, Дмитро Кравченко, Роман Білинський, Денис Гриценко).
* **Спільнота 46 (17 вузлів):** Кластер інфраструктури та підтримки (Андрій Руденко, Василь Горобець, Юрій Степаненко).
* **Спільнота 113 (16 вузлів):** QA та автоматизація (Олена Олійник, Наталія Марченко, Христина Мельник).
* **Спільнота 45 (15 вузлів):** Frontend-розробка (Юлія Ткаченко, Оксана Лисенко, Катерина Білоус).
* **Спільнота 126 (14 вузлів):** Реляційні СКБД та робота з даними (PostgreSQL, Анна Шевченко, Марія Сидоренко).
* **Спільнота 141 (14 вузлів):** Python/Django розробники (Django, Максим Бондаренко, Богдан Мороз, Ірина Козак).

---

## 2. Змістовна інтерпретація для предметної області (Критерій C2)

Застосування алгоритму PageRank виявило, що найвищі показники центральності в графі займають ключові технологічні навички: Django (2.2002), TypeScript (2.1776), Neo4j (2.0876), React (1.9793) та CI/CD (1.6437), а також комплексні посади рівня Senior/Architect. Для предметної області рекрутингу це свідчить про те, що зазначені стеки формують фундаментальні технологічні хаби, через які проходить найбільша частка вакансій ринку та пулу кандидатів.

Алгоритм Louvain успішно сегментував граф знань на стійкі кластери, кожен з яких відповідає окремій ринковій спеціалізації (Highload/C++, Frontend, Python/Django, QA, Бази даних). Для рекрутингової системи це забезпечує оптимізований контекстний пошук: замість глобального пошуку по всьому ринку система звужує підбір до конкретної спільноти, підвищуючи релевантність рекомендацій та прискорюючи закриття вакансій.

---

## 3. Оптимізація запитів за допомогою PROFILE (Критерій C3)

Для аналізу продуктивності обрано фільтрацію кандидатів за географічною ознакою:
```cypher
PROFILE MATCH (c:Candidate) WHERE c.city = 'Львів' RETURN c.name, c.expected_salary;
```

* **ДО оптимізації:** Відсутній індекс за полем `city`. Виконавець Cypher застосовує повне сканування мітки `NodeByLabelScan`, перевіряючи всі 35 вузлів Candidate. Загальна кількість звернень до бази даних: **83 database accesses**.
* **Дія:** Створено специфічний індекс:
  ```cypher
  CREATE INDEX candidate_city_idx IF NOT EXISTS FOR (c:Candidate) ON (c.city);
  ```
* **ПІСЛЯ оптимізації:** Оператор замінено на прямий доступ за індексом `NodeIndexSeek`. Загальна кількість звернень до сховища скоротилася до **12 database accesses** (зменшення навантаження на СКБД на $\approx 85\%$).

---

## 4. Збереження результатів у властивості вузлів (Критерій C4)

Значення метрик збережено безпосередньо у вузлах графа:
```cypher
// Запис PageRank
CALL gds.pageRank.write('recruitmentGraph', {
  writeProperty: 'pagerank'
});

// Запис Community ID
CALL gds.louvain.write('recruitmentGraph', {
  writeProperty: 'community'
});
```

Верифікація збережених властивостей:
```cypher
MATCH (s:Skill)
RETURN s.name AS Skill, round(s.pagerank, 4) AS PageRank, s.community AS Community
ORDER BY s.pagerank DESC
LIMIT 5;
```
