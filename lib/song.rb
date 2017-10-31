require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize #Pluralize requires 'inflector' above
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    #will give results like this:
    #[{"cid"=>0,"name"=>"id","type"=>"INTEGER","notnull"=>0,"dflt_value"=>nil,"pk"=>1,0=>0,1=>"id",2=>"INTEGER",...

    sql = "pragma table_info('#{table_name}')" #Pragma -> query table for the names of its columns

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"] #pull vale of key named 'name'
    end
    column_names.compact #get rid of any 'nil' values, should look like ["id", "name", "album"]
  end

  self.column_names.each do |col_name| #metaprogramming of class attributes
    attr_accessor col_name.to_sym #change string to symbol as attributes need to be symbols :example
  end

  def initialize(options={}) #argument passed will be hash and defaults to empty hash
    options.each do |property, value|
      self.send("#{property}=", value) #write attribute values into instance
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name #intance method calling a class method -> self.class
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil? #the 'send' will extract the values from the instance
    end
    values.join(", ") #change from array to string seperated by commas
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #column_names will look like ["id", "name", "album"], we want to get rid of the id since the SQL assigns those
    #change array into string seperated by commas
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
