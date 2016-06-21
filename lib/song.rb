require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

# taking name of class and uncapitalizing, 
# pluralizing and changing it to a symbol
  def self.table_name
    self.to_s.downcase.pluralize
  end

# creating cloumn names for sql
# makes sure results of DB[:conn] come as hash
# pragma gets table info via sql from table
# it comes via a big ugly hash
# so we call .each to extrapolate the column names
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

# here we make each column name into an accessor 
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

# use .send to write values of each accessor
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

# the usual save stuff but without actually naming anything
# so that we can use it in multiple classes
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

# making code concise, oo stuff
  def table_name_for_insert
    self.class.table_name
  end

# creating an array with each value
# send col_name gets us the isntances values
# and then we join them for sql
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



