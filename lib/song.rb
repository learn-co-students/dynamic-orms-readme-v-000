require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class Song


  def self.table_name
    z = self.to_s.downcase.pluralize
    # binding.pry
    z
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
      # binding.pry
    end
    column_names
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
    # binding.pry
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
      # binding.pry
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # binding.pry
  end

  def table_name_for_insert
    x = self.class.table_name
    # binding.pry
    x
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
      # binding.pry
    end
    values.join(", ")
  end

  def col_names_for_insert
    z = self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    # binding.pry
    z
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    x = DB[:conn].execute(sql)
    # binding.pry
    x
  end

end
