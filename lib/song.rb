require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
  end

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

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property, value|
      send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert.join(", ")})"
    DB[:conn].execute(sql)
  end

  def values_for_insert
    self.class.column_names.map do |col_name|
      "'#{public_send(col_name)}'" unless public_send(col_name).nil?
    end.compact
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def find_by_name(name)
    sql = "SELECT * FROM #{self.class.table_name} WHERE name = #{name}"
    DB[:conn].execute(sql)
  end

end



