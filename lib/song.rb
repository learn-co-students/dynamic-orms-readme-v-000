require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  #STEP 2
  #use the songs table column names to dynamically create the attr_accessor's of Song class
    #need to query for columns names  

  def self.table_name #class method that grabs table name
    self.to_s.downcase.pluralize
  end

  def self.column_names #class method that grabs columns names
    #queries table for column names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"

    #iterate over query just collecting column names
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact #compact get rids of nil values
  end

  # iterate of column names stored in column_names class method & 
  # set an attr_accessor for each one
  self.column_names.each do |col_name| 
    attr_accessor col_name.to_sym
  end


  #STEP 3 
  #builing an abstract initialize method

  def initialize(options={})  #method take in an agrument options = empty hash
    options.each do |property, value|
      self.send("#{property}=", value) #.send interpolate the name of each hash as a method that we set equals to key's value
    end
  end

  #STEP 4
  #writing ORM (object relational mapping) methods save and find_by_name

  def save
    # INSERT INTO songs (name, album) VALUES ?, ?
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #def self.xxxx   = class method & self refers to class Song
  #end 

  #def xxxx  = instance method 
    #self.xxxx   => self refers to instance xxxx of the class Song 
    #self.class.xxxx  => self.class gives status class and can call arguments on the class
  #end  
  
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #self.class.column_names returns ["id", "name", "album"]
    
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") 
    # returns ["name", "album"]  removes "id" from array
    # then joins "name, album"
  end

  def values_for_insert
    values = []
 
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end


#select rocords 
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



