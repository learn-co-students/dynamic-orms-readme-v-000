ORMS and SQL Joins Lecture Notes:

class Cart
  attr_accessor :id, :customer_id

  def customer
    the_id_i_need_to_query = self.customer_id
    # I need to query it from the customers table itself-- using ruby to find customer_id, then once I have that using SQL to make the query.
    row = DB[:connection].execute("select * from customers where id = ?", self.customer_id)
  end

  def self.find(id)
    row = DB[:connection].execute("select * from carts where id = ?", id)
    Cart.reify_from_row(row.flatten)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS carts (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER
      )
      SQL
      DB[:connection].execute(sql)
    end
  end

  def save
    # some code here
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM carts
    SQL
    rows = DB[:connection].execute(sql)

    Cart.reify_from_rows(rows)
  end

  def self.reify_from_rows(rows)
    rows.collect{|r| reify_from_row(r)}
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.customer_id = row[1]
    end
  end
end

# in rakefile:
# def reload!
#   load_all './lib'
# end
#
# task :console do
#   Pry.start
# end

class LineItem
  attr_accessor :id, :cart_id, :product_id

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS line_items (
        id INTEGER PRIMARY KEY,
        cart_id INTEGER,
        product_id INTEGER
      )
      SQL
      DB[:connection].execute(sql)
    end
  end

  def self.find(id)
    sql = "SELECT * FROM line_items where id = ?"
    row = DB[:connection].execute(sql, id).flatten
    # without flattening - get back [[1, 1, 1]]
    self.reify_from_row(row)
  end

  def cart
    cart_id = self.cart_id
    # first find cart_id self.cart_id
    sql = "SELECT * FROM carts WHERE cart_id = ?"
    row = DB[:connection].execute(sql, cart_id).flatten
    # the information about a cart
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.cart_id = row[1]
      o.product_id = row[2]
    end
  end
end

class Customer
  # A cart belongs to a customer, and a customer has many carts
  attr_accessor :id, :name

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
      SQL
      DB[:connection].execute(sql)
    end
  end

  def self.find(id)
    row = DB[:connection].execute("SELECT * FROM customers where id = ?", id)
    Customer.reify_from_row(row.flatten)
  end

  def carts
    customer_id = self.id
    rows = DB[:connection].execute("SELECT * FROM carts WHERE carts.customer_id = ?", self.id)
    Cart.reify_from_rows(rows)
    # [[cart information], [cart_information]]
    # has many relationship with example of avi having two carts
  end

  def self.reify_from_rows(rows)
    rows.collect{|r| reify_from_row(r)}
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.name = row[1]
    end
  end
end

class Product
  attr_accessor :id, :name, :price

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        price INTEGER
      )
      SQL
      DB[:connection].execute(sql)
    end
  end

  def self.find(id)
    row = DB[:connection].execute("SELECT * FROM products where id = ?", id)
    Product.reify_from_row(row.flatten)
  end

  def customers
    # id = self.id
    # to get back my customers
    sql = <<-SQL
      SELECT DISTINCT(customers.id), customers.name FROM customers
      INNER JOIN carts ON customers.id = carts.customer_id
      INNER JOIN line_items ON carts.id = line_items.cart_id
      WHERE line_items.products_id = ?;
    SQL

    # SELECT DISTINCT(customers.id), customers.* FROM customers
    # INNER JOIN carts ON customers.id = carts.customer_id
    # INNER JOIN line_items ON carts.id = line_items.cart_id
    # WHERE line_items.products.id = 1;

    rows = DB[:connection].execute(sql, self.id)
    Customer.reify_from_rows(rows)
  end

  def self.reify_from_rows(rows)
    rows.collect{|r| reify_from_row(r)}
  end

  def self.reify_from_row(row)
    self.new.tap do |o|
      o.id = row[0]
      o.name = row[1]
      o.price = row[2]
    end
  end
end

Information in the Repl:

CREATE TABLE IF NOT EXISTS carts (
  id INTEGER PRIMARY KEY,
  customer_id INTEGER
);

CREATE TABLE IF NOT EXISTS line_items (
  id INTEGER PRIMARY KEY,
  cart_id INTEGER,
  product_id INTEGER
);

CREATE TABLE IF NOT EXISTS customers (
  id INTEGER PRIMARY KEY,
  name TEXT
);

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY,
  name TEXT,
  price INTEGER
);

INSERT INTO products (name, price) VALUES ("iPhone", 2), ("Radio", 1);

INSERT INTO carts (customer_id) VALUES (1), (2), (1);

INSERT INTO customers (name) VALUES ("Avi"), ("Jeff");

INSERT INTO line_items (cart_id, product_id) VALUES (1, 1), (1, 2), (2, 1), (3, 1);
