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
  quantity INT NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL
);

INSERT INTO products(name,category,price,old_price,image,description,stock) VALUES
('Classic Chelsea Boot','Chelsea Boots',6999,8999,'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?auto=format&fit=crop&w=900&q=85','Premium leather Chelsea boots with elastic side panels.',25),
('Urban Leather Sneaker','Sneakers',5499,6999,'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85','Minimal leather sneakers for daily wear.',35),
('Executive Formal Shoe','Formal Shoes',6299,7999,'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=900&q=85','Classic formal footwear for office and events.',20),
('Desert Casual Boot','Casual Boots',5799,7499,'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=900&q=85','Rugged casual boots with a comfortable sole.',22),
('Premium Loafer','Loafers',5199,6499,'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=900&q=85','Smart slip-on loafers for a polished look.',18)
ON CONFLICT DO NOTHING;
