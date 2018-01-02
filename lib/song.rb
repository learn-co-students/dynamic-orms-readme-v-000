require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name                           #takes class name into string/lowercase/pluralize
    self.to_s.downcase.pluralize
  end

  def self.column_names                         #query table for col names, return hash
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]                   #grab just the name of each column
    end
    column_names.compact
  end

  self.column_names.each do |col_name|              #convert string to symbol bc attr_accessor must be named with symbols
    attr_accessor col_name.to_sym
  end

  def initialize(options={})                        #takes in argument set as empty hash
    options.each do |property, value|               #use send method to grab name of hash key as a method to set to the value
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert                   #grabs the table name we set earlier
    self.class.table_name
  end

  def values_for_insert                       #iterate over col names and use send to
    values = []                               #invoke method by that name ans capture value
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert                   #grab column names except id
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
