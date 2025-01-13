-- Создание таблиц
-- Клиенты
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE,
    loyalty_points INT DEFAULT 0 CHECK(loyalty_points >= 0),
    CONSTRAINT chk_email CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    CONSTRAINT chk_phone_number CHECK (phone_number ~* '^\+?[0-9]{1,15}$')
);

-- Заказы
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    order_num SERIAL NOT NULL,
    customer_id UUID NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) CHECK(total_amount >= 0),
    status VARCHAR(10) DEFAULT 'Создан' CHECK(status IN ('Создан', 'Оплачен', 'Готов к выдаче', 'Выдан', 'Отменен')),
    delivery_method VARCHAR(10) DEFAULT 'В зале' CHECK(delivery_method IN ('В зале', 'С собой')),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    UNIQUE (order_num, customer_id)
);

CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);

--Меню
DROP TABLE IF EXISTS menu CASCADE;
CREATE TABLE menu (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    "name" VARCHAR(50) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

--Товары
DROP TABLE IF EXISTS items CASCADE;
CREATE TABLE items (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    menu_id UUID  NOT NULL REFERENCES menu(id) ON DELETE cascade,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(20),
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK(price > 0),
    discount DECIMAL(10, 2) DEFAULT 0 CHECK(discount >= 0),
    calories INT,
    proteins INT,
    fats INT,
    carbs INT,
    allergens TEXT,
    image_url TEXT,
    is_custom BOOLEAN DEFAULT FALSE
);

-- Ингредиенты
DROP TABLE IF EXISTS ingredients CASCADE;
CREATE TABLE ingredients (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    "name" VARCHAR(250) unique NOT NULL,
    description TEXT,
    image_url TEXT,
    is_required BOOLEAN DEFAULT FALSE
);

-- Связь товар-ингридиент
DROP TABLE IF EXISTS item_ingridient;
CREATE TABLE item_ingridient (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    ingredient_id UUID NOT NULL,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE RESTRICT
);

--Корзина
DROP TABLE IF EXISTS cart;
CREATE TABLE cart (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID,
    item_id UUID  NOT NULL REFERENCES items(id) ON DELETE RESTRICT,
    quantity INT DEFAULT 1 CHECK(quantity > 0),
    total_amount DECIMAL(10, 2) CHECK(total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE INDEX idx_cart_customer_id ON cart(customer_id);
CREATE INDEX idx_cart_item_id ON cart(item_id);

-- Платежи
DROP TABLE IF EXISTS payments CASCADE;
CREATE TABLE payments (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK(amount >= 0),
    "method" VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'ожидает подтверждения' CHECK(status IN ('Ожидает подтверждения', 'Оплачен', 'Отменен')),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Бонусы
DROP TABLE IF EXISTS bonuses CASCADE;
CREATE TABLE bonuses (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL,
    bonus_value DECIMAL(10, 2) NOT NULL CHECK(bonus_value >= 0),
    status VARCHAR(100) DEFAULT 'активны',
    creation_date DATE DEFAULT CURRENT_DATE,
    expiration_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);



--Генерация данных
INSERT INTO customers (first_name,last_name, phone_number,email,loyalty_points) VALUES 
( 'Иван','Иванов', '+79777491345', 'ivanov@mail.ru',50),
( 'Петр', 'Петров', '+79777491346', 'petrov@mail.ru', 100),
( 'Афанасий','Сидоров', '+79777491347', 'sidorov@mail.ru', 500),
( 'Александр','Болдырев', '+79777491343', 'boldyrev@mail.ru', 1000),
( 'Алексей','Парамчук', '+79777491341', 'pl@mail.ru', 5000);

INSERT INTO orders (customer_id,total_amount, status) VALUES 
( '356f5450-38fc-43ff-9986-0d69ae7f4b09',200, 'Выдан'),
( '356f5450-38fc-43ff-9986-0d69ae7f4b09',300, 'Создан'),
( '1900e786-bc82-4f40-a20b-0190c4e73f54',400, 'Создан'),
( '1900e786-bc82-4f40-a20b-0190c4e73f54',500, 'Выдан'),
( 'edb2bcc2-6232-49e0-a02e-85b89b930fd3',600, 'Выдан'),
( 'f1977aa6-2c00-4afc-a255-6cda9cdddf48',700, 'Выдан'),
( 'f1977aa6-2c00-4afc-a255-6cda9cdddf48',800, 'Выдан'),
( 'f1977aa6-2c00-4afc-a255-6cda9cdddf48',900, 'Отменен'),
( '0f752eb5-9071-473a-a486-86af8c40c627',100, 'Выдан'),
( '0f752eb5-9071-473a-a486-86af8c40c627',200, 'Выдан');

INSERT INTO menu ("name",is_active) VALUES 
( 'usual',TRUE),
( 'summer',false);

INSERT INTO items (menu_id,name, category, description, price, calories,proteins, fats, carbs, allergens, image_url,is_custom) VALUES 
( 'a1a13e9e-8e88-4115-b2ab-9f8c2b05af48','Яблочный сок', 'Напитки','Самый вкусный сок',50.0,200,20,30,40,'Глютен', 'https://example.com/wheat_flour.png', FALSE),
( '8d017a88-ea3d-4328-88c6-fe97127ed6a4','Картошка фри', 'Картошка', 'Вкуснейшая картошка',100.50,300,50,60,40,'Глютен', 'https://example1.com/wheat_flour.png', FALSE),
( '8d017a88-ea3d-4328-88c6-fe97127ed6a4','Кола', 'Напитки', 'Лучшая кола', 70.0,500,70,40,20,'Глютен', 'https://example2.com/wheat_flour.png', FALSE),
( '8d017a88-ea3d-4328-88c6-fe97127ed6a4','Нагетсы', 'Нагетсы' , 'Хрустящие нагетсы',150.0,500,70,40,20,'Глютен', 'https://example3.com/wheat_flour.png', FALSE),
( '8d017a88-ea3d-4328-88c6-fe97127ed6a4','Комбо-Бургер', 'Бургеры' , 'Бургер с говядиной',250.50,800,50,100,20,'Глютен', 'https://example4.com/wheat_flour.png', TRUE);

INSERT INTO ingredients (name, description, image_url, is_required) VALUES 
( 'Сыр','Плавленый сыр' ,'https://example.com/wheat_flour.png', FALSE),
( 'Булочка','Булочка с кунжутом' ,'https://example4.com/wheat_flour.png', TRUE),
( 'Котлета','Котлета с говядиной' ,'https://example9.com/wheat_flour.png', TRUE)

INSERT INTO item_ingridient (item_id, ingredient_id) VALUES 
( 'cebf4a6d-bca6-4051-b58c-78c2e1cfa07e','3fcb73bc-e256-4bc0-9830-eadd8a0231c7'),
( 'cebf4a6d-bca6-4051-b58c-78c2e1cfa07e','af02d9b0-8b3c-41b5-b7c6-70367cc15b57'),
( 'cebf4a6d-bca6-4051-b58c-78c2e1cfa07e','4369e199-e64b-4302-8c3d-32a2defb4f35')

INSERT INTO cart (customer_id, item_id, quantity, total_amount ) VALUES 
( '356f5450-38fc-43ff-9986-0d69ae7f4b09','35058f43-2792-4f09-a6f3-015e0aaf6284',1,100),
( '356f5450-38fc-43ff-9986-0d69ae7f4b09','e033f4e4-ac9f-438c-8520-372b330d7cb2',2,200),
( '356f5450-38fc-43ff-9986-0d69ae7f4b09','2fe66724-3d16-4961-8ffd-2a96322bc5d5',1,100)

INSERT INTO payments (order_id, amount, method, status ) VALUES 
( 'e3dab5c3-6f84-4ed5-9533-8aca7e2224e3',200,'Карта','Оплачен'),
( 'e3dab5c3-6f84-4ed5-9533-8aca7e2224e3',300,'Карта','Оплачен'),
( '611af6cd-ae1e-4379-8ae9-4346bff29016',400,'Карта','Оплачен'),
( '54a6f811-404b-4521-ab73-3a4b7b0069da',500,'Карта','Оплачен'),
( 'f4f952a8-e5af-4b2a-9528-55e47a744d70',600,'Карта','Оплачен'),
( '77b52180-bd16-4c68-ab24-5411ba6acbbe',700,'Карта','Оплачен'),
( 'ca56e8c4-cbe8-4514-b187-ee8a3d3922a3',800,'Бонусы','Оплачен'),
( '06fdeae0-eadc-44fd-831f-47eff377e34a',900,'Карта','Отменен'),
( '8d2f89a1-99b0-49ce-a250-5f91814abd9c',100,'Карта','Оплачен'),
( '5c1fba92-8e5b-48ec-8fa4-de608d19047d',200,'Бонусы','Оплачен')

INSERT INTO bonuses (customer_id, bonus_value, status,creation_date, expiration_date ) VALUES 
( '356f5450-38fc-43ff-9986-0d69ae7f4b09',50,'активны','2024-01-01','2026-01-01'),
( '1900e786-bc82-4f40-a20b-0190c4e73f54',100,'активны','2024-01-01','2026-01-01'),
( 'edb2bcc2-6232-49e0-a02e-85b89b930fd3',500,'активны','2024-01-01','2026-01-01'),
( 'f1977aa6-2c00-4afc-a255-6cda9cdddf48',1000,'активны','2024-01-01','2026-01-01'),
( '0f752eb5-9071-473a-a486-86af8c40c627',2000,'активны','2024-01-01','2026-01-01'),
( '0f752eb5-9071-473a-a486-86af8c40c627',3000,'активны','2025-01-01','2027-01-01')
