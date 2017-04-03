require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql) #table_info is an array of hashes
    column_names = []
    # binding.pry
    table_info.each do |row| #row is a hash corresponding to a column
      column_names << row["name"] #["name"] is the key corresponding to the column's name
    end
    # binding.pry
    column_names.compact #compact removes nil elements
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    # binding.pry
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    # binding.pry
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # binding.pry
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end #returns array of strings equal to column names
    # binding.pry
    values.join(", ") #joins elements into single string, each separated by ", "
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #column_names returns array, this method joins elements into single string
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
