CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL, -- director, head_of_dept, deputy_head
    department VARCHAR(50) NOT NULL -- production, sales, all
);

CREATE TABLE crm_clients (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    segment VARCHAR(20), -- B2B, B2C
    status VARCHAR(20),  -- active, churned
    lifetime_value DECIMAL(10,2)
);

CREATE TABLE crm_tickets (
    ticket_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES crm_clients(customer_id),
    topic VARCHAR(100),
    channel VARCHAR(50),
    sla_status VARCHAR(20), -- met, violated
    created_at TIMESTAMP,
    resolved_at TIMESTAMP,
    responsible_user_id INT REFERENCES users(id)
);

CREATE TABLE erp_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES crm_clients(customer_id),
    product_id INT,
    amount DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'BYN',
    status VARCHAR(50), -- принят, модерация, производство, готов, доставлен, брак
    channel VARCHAR(50),
    created_at TIMESTAMP,
    deadline TIMESTAMP,
    completed_at TIMESTAMP,
    defect_flag BOOLEAN DEFAULT FALSE
);

CREATE TABLE documents_meta (
    doc_id SERIAL PRIMARY KEY,
    filename VARCHAR(200) NOT NULL,
    title VARCHAR(200) NOT NULL,
    department VARCHAR(50),
    access_roles VARCHAR(200) -- строка с ролями через запятую
);

CREATE TABLE meetings (
    meeting_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    date TIMESTAMP,
    participants VARCHAR(200),
    agenda TEXT,
    transcript_text TEXT
);

CREATE TABLE tasks (
    task_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    owner_id INT REFERENCES users(id),
    deadline TIMESTAMP,
    status VARCHAR(50),
    priority VARCHAR(20),
    source_meeting_id INT REFERENCES meetings(meeting_id),
    source_document_id INT REFERENCES documents_meta(doc_id)
);

-- ==========================================
-- 2. НАПОЛНЕНИЕ ДАННЫМИ
-- ==========================================

-- Пользователи (3 роли)
INSERT INTO users (name, email, role, department) VALUES
('Иванов Иван Иванович', 'director@fotoprint.by', 'director', 'all'),
('Петров Петр Петрович', 'petrov@fotoprint.by', 'head_of_dept', 'production'),
('Сидоров Сидор Сидорович', 'sidorov@fotoprint.by', 'deputy_head', 'production'),
('Смирнова Анна', 'smirnova@fotoprint.by', 'head_of_dept', 'sales'),
('Кузнецов Олег', 'kuznetsov@fotoprint.by', 'deputy_head', 'sales');

-- Клиенты (имитация 200)
INSERT INTO crm_clients (name, segment, status, lifetime_value) VALUES
('ООО "Ромашка"', 'B2B', 'active', 15000),
('ИП Сидоров', 'B2B', 'active', 3200),
('Мария Иванова', 'B2C', 'churned', 450),
('ООО "СтройТрест"', 'B2B', 'active', 89000),
('Алексей Смирнов', 'B2C', 'active', 1200);
-- (Программист может размножить это через generate_series до 200)

-- Обращения (имитация 300)
INSERT INTO crm_tickets (customer_id, topic, channel, sla_status, created_at, resolved_at, responsible_user_id) VALUES
(1, 'Брак', 'email', 'met', '2026-10-01 10:00:00', '2026-10-02 12:00:00', 2),
(2, 'Доставка', 'chat', 'violated', '2026-10-03 14:30:00', '2026-10-06 09:00:00', 3),
(3, 'Оплата', 'phone', 'met', '2026-10-05 11:00:00', '2026-10-05 11:30:00', 4);

-- Заказы (имитация 500)
INSERT INTO erp_orders (customer_id, product_id, amount, status, channel, created_at, deadline, completed_at, defect_flag) VALUES
(1, 3, 1500.00, 'доставлен', 'сайт', '2026-09-01 10:00:00', '2026-09-05 18:00:00', '2026-09-04 12:00:00', FALSE),
(2, 1, 450.00, 'брак', 'приложение', '2026-09-02 11:00:00', '2026-09-06 18:00:00', '2026-09-06 10:00:00', TRUE),
(4, 5, 8000.00, 'производство', 'офис', '2026-09-03 09:00:00', '2026-09-10 18:00:00', NULL, FALSE);

-- Документы (20 штук, разные права)
INSERT INTO documents_meta (filename, title, department, access_roles) VALUES
('strategy_2027.txt', 'Стратегия развития 2027', 'all', 'director'),
('finance_q3.txt', 'Финансовый отчет Q3', 'finance', 'director'),
('hr_salaries.txt', 'Штатное расписание и зарплаты', 'hr', 'director'),
('sales_scripts.txt', 'Скрипты продаж', 'sales', 'director,head_of_dept'),
('production_regulations.txt', 'Регламент производства', 'production', 'director,head_of_dept'),
('safety_instructions.txt', 'Инструкция по охране труда', 'all', 'director,head_of_dept,deputy_head'),
('machine_checklist.txt', 'Чек-лист наладки станка', 'production', 'director,head_of_dept,deputy_head'),
('client_brief.txt', 'Бриф для клиента', 'sales', 'director,head_of_dept'),
('delivery_rules.txt', 'Правила доставки', 'all', 'director,head_of_dept,deputy_head'),
('moderation_policy.txt', 'Политика модерации', 'production', 'director,head_of_dept'),
('marketing_plan.txt', 'Маркетинговый план', 'sales', 'director,head_of_dept'),
('it_security.txt', 'ИТ безопасность', 'it', 'director'),
('waste_report.txt', 'Отчет по браку', 'production', 'director,head_of_dept'),
('b2b_contract_template.txt', 'Шаблон договора B2B', 'sales', 'director,head_of_dept'),
('picpac_catalog.txt', 'Каталог picPac.by', 'all', 'director,head_of_dept,deputy_head'),
('attendance_policy.txt', 'Политика посещаемости', 'hr', 'director,head_of_dept,deputy_head'),
('quality_standards.txt', 'Стандарты качества', 'production', 'director,head_of_dept'),
('crisis_plan.txt', 'Кризисный план', 'all', 'director'),
('client_feedback.txt', 'Обратная связь клиентов', 'sales', 'director,head_of_dept'),
('equipment_log.txt', 'Журнал оборудования', 'production', 'director,head_of_dept,deputy_head');

-- Встречи (3 штуки с расшифровками)
INSERT INTO meetings (title, date, participants, agenda, transcript_text) VALUES
('Планерка по срокам заказа', '2026-10-15 10:00:00', '1,2,3', 'Сроки производства', 
'Иванов: Коллеги, добрый день. Обсудим сроки по заказу №455. Петров, доложите. Петров: Мы отстаем от графика. Есть риск, что поставщик бумаги подведет на этой неделе. Сидоров: Можем перераспределить смены. Иванов: Решили: финальный срок — 15 ноября. Петров, подготовь план смен к пятнице. Сидоров, проконтролируй готовность оборудования к 10 ноября.'),
('Анализ брака', '2026-10-16 14:00:00', '1,2', 'Причины брака', 
'Иванов: За прошлый месяц 5% брака. Это много. Петров: Проблема в настройке станка №3. Сидоров: Нужно обучение персонала. Иванов: Решили: провести обучение до конца месяца. Петров, организуй.'),
('Встреча с клиентом', '2026-10-17 11:00:00', '1,4', 'Скидки для B2B', 
'Смирнова: Клиент просит скидку 10%. Иванов: Согласовали скидку 5% при заказе от 1000 BYN. Смирнова, подготовь КП и отправь клиенту до завтра.');

-- Задачи (связь с встречами и без ответственного)
INSERT INTO tasks (title, owner_id, deadline, status, priority, source_meeting_id, source_document_id) VALUES
('Подготовить план смен', 2, '2026-10-20 18:00:00', 'in_progress', 'high', 1, NULL),
('Проверить оборудование', 3, '2026-11-10 18:00:00', 'todo', 'medium', 1, NULL),
('Сделать отчет по браку', NULL, NULL, 'todo', 'high', 2, NULL), -- БЕЗ ОТВЕТСТВЕННОГО
('Согласовать скидку', 4, '2026-10-25 18:00:00', 'done', 'high', 3, 3), -- Связана с документом
('Провести обучение персонала', 2, '2026-10-30 18:00:00', 'todo', 'high', 2, NULL);

-- ==========================================
-- 3. ПРОВЕРКИ (для README и демо)
-- ==========================================
-- Задача без ответственного:
-- SELECT task_id, title FROM tasks WHERE owner_id IS NULL;
-- Связь встреча -> задача:
-- SELECT t.title AS task, m.title AS meeting FROM tasks t JOIN meetings m ON t.source_meeting_id = m.meeting_id;
-- KPI по заказам:
-- SELECT status, COUNT(*) FROM erp_orders GROUP BY status;