require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  #To switch the Class Name to lowercase, and add "s" at the end
  def self.table_name
    self.to_s.downcase.pluralize
  end

  #To obtain the column names from the table
  def self.column_names
    DB[:conn].results_as_hash = true

    #pragma_table_info displays all the info regarding a table
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  #convert each column name to an attr_accessor
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  #initialize using metaprogramming; the argument provided is an empty hash by default
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #To save the instance into the DB
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #To obtain the table name via an instance method from the original Class Method "self.table_name" above
  def table_name_for_insert
    self.class.table_name
  end

  #To collect the values for each column, add ' around them, and combine into one string separated by a ", "
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  #To remove the id column for INSERT, and combine them into one string separated by a ", "
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  #Find an instance by name
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
