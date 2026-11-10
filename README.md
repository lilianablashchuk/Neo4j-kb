## 1. Версії та вимоги
- **ОС:** Windows 10/11
- **Neo4j Desktop:** 1.5+ (Neo4j DBMS 5.x)
- **Плагін:** Graph Data Science (GDS) 2.6+
- **Python:** 3.10+
- **Random Seed:** `42`

## 2. Залежності (PowerShell)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install pandas neo4j 
```

## 3. Генерація даних
```powershell
python scripts/generate_data.py --seed 42
```

## 4. Запуск у Neo4j Desktop
1. Створіть локальну базу (DBMS 5.x) та встановіть пароль.
2. У вкладці **Plugins** натисніть **Install** напроти **Graph Data Science (GDS)**.
3. Через меню бази відкрийте `Open folder` -> `Import` та скопіюйте туди файли з папки `data/`.
4. Запустіть базу (**Start**) та відкрийте **Neo4j Browser**.

## 5. Завантаження та виконання
1. Створіть обмеження та виконайте імпорт CSV (скрипти з папки `cypher/import.cypher`).
2. Виконайте аналітичні запити та GDS (PageRank, Louvain).
3. Перевірка 10 питань Text-to-Cypher: `tests/t2c.jsonl`.