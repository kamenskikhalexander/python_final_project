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
