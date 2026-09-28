CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(180) UNIQUE NOT NULL,
  phone VARCHAR(40),
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  category VARCHAR(100) NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  old_price NUMERIC(12,2) NOT NULL,
  image TEXT NOT NULL,
  description TEXT NOT NULL,
  stock INT NOT NULL DEFAULT 20,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id),
  total NUMERIC(12,2) NOT NULL,
  payment_method VARCHAR(30) NOT NULL,
  shipping_address TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(id),
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_transactions (
  id SERIAL PRIMARY KEY,
  order_id INT REFERENCES orders(id) ON DELETE SET NULL,
  user_id INT NOT NULL REFERENCES users(id),
  method VARCHAR(30) NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  merchant_number VARCHAR(40) NOT NULL,
  transaction_reference VARCHAR(120),
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 100 catalogue records with real image URLs, prices, discounts and stock.
-- The image set is intentionally reused across variants so the database remains lightweight.
WITH data AS (
  SELECT
    gs AS n,
    (ARRAY['Chelsea Boots','Sneakers','Formal Shoes','Casual Boots','Loafers','Running Shoes','Sandals','Slides','Hiking Boots','Driving Shoes'])[1 + ((gs - 1) % 10)] AS category,
    (ARRAY['Classic','Premium','Urban','Heritage','Executive','Street','Sport','Comfort','Elite','Signature'])[1 + ((gs - 1) % 10)] AS style,
    (ARRAY[
      'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1605812860427-4024433a5c2d?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1449255618147-768b0f3f5eeb?auto=format&fit=crop&w=900&q=85',
      'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=900&q=85'
    ])[1 + ((gs - 1) % 10)] AS image
  FROM generate_series(1,100) AS gs
)
INSERT INTO products(name, category, price, old_price, image, description, stock)
SELECT
  style || ' ' || category || ' ' || LPAD(n::text, 3, '0'),
  category,
  2999 + ((n - 1) % 15) * 300,
  3999 + ((n - 1) % 15) * 300,
  image,
  'Premium ' || LOWER(category) || ' designed for everyday Pakistani style, comfort and durability.',
  10 + ((n - 1) % 40)
FROM data
ON CONFLICT DO NOTHING;
