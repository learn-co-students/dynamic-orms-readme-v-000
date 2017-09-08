require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize #Song-->song-->songs
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #returns a lot of info with column names included, must grab just those
    # [{"cid"=>0,
    #  "name"=>"id", ---**
    #  "type"=>"INTEGER",
    #  "notnull"=>0,
    #  "dflt_value"=>nil,
    #  "pk"=>1,
    #  0=>0,
    #  1=>"id",
    #  2=>"INTEGER",
    #  3=>0,
    #  4=>nil,
    #  5=>1},
    # {"cid"=>1,
    #  "name"=>"name", ---**
    #  "type"=>"TEXT",
    #  "notnull"=>0,
    #  "dflt_value"=>nil,
    #  "pk"=>0,
    #  0=>1,
    #  1=>"name", ---***
    #  2=>"TEXT",
    #  3=>0,
    #  4=>nil,
    #  5=>0},
    # {"cid"=>2,
    #  "name"=>"album", --***
    #  "type"=>"TEXT",
    #  "notnull"=>0,
    #  "dflt_value"=>nil,
    #  "pk"=>0,
    #  0=>2,
    #  1=>"album",
    #  2=>"TEXT",
    #  3=>0,
    #  4=>nil,
    #  5=>0}]

    #we just need the name keys that point to values

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"] #wherever the hash key is equal to "name", we add it to our column names
    end
    column_names.compact #gets rid of any nil values
  end

  self.column_names.each do |col_name| #for each column names, we change it to a symbol (name:)
    attr_accessor col_name.to_sym
  end

  def initialize(options={}) #setting the column names as a property with a value using send, corresponds with attr_accessor
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save #use info from other methods to insert and save values into table
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert #abstracting the name of the table to insert from PRAGMA
    self.class.table_name #self is an instance of the class method .table_name, returns "songs"
  end

  def values_for_insert #abstracting the colum values to insert from PRAGMA
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert #abstracting the column names to insert from PRAGMA
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") #want to get rid of id, not created in ruby objects
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
