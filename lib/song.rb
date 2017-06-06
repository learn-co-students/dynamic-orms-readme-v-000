require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

#------------------------------------------------------------------------
#macros and meta
#NOTE these must come first because of hoisting (i think)
#so when self.column_names.each... is called, it has the necc. methods avail

#converts class name to name for sql table
def self.table_name
  self.to_s.downcase.pluralize
end


#generates column names from an existing db table~
def self.column_names
  #this pulls the column names using pragma
  #it specifies that they be returned in a hash
  DB[:conn].results_as_hash = true
  sql = "pragma table_info('#{self.class.table_name}')"
  table_info = DB[:conn].execute(sql)
  

  column_names = []
  table_info.each {|row|
                    column_names << row["name"]
                    #this seems to be just housekeeping (the compact)
                    #you shouldn't have any nils   
                  }

column_names.compact                  
end
#*not a method*make the attr_accessors for each column name
self.column_names.each {|col_name| attr_accessor col_name.to_sym}
  






#------------------------------------------------------------------------
#instance (above constraints notwithstanding)

def initialize(options)
options.each { |key, value| self.send("#{key}=", value) }
end

#extension - ** we did not use original table_name
#even though they're the same, tihs gives us flex in future
def table_name_for_insert
self.class.table_name
end

#note that this is grabbing raw values from the attr_acessor methods
#via #send(col_name)
def values_for_insert
  values = []
  self.class.column_names.each { |col_name| values << "'#{send(col_name)}'" unless send(col_name).nil? }
  values.join(", ")
end

#extension - did not use orig column names
#this was necc, not just good house keeping
#because we can't insert id - so have to get rid of that
def col_names_for_insert
  self.class.column_names.delete_if {|col| col == "id"}.join(", ")
end

#this just combines col_names, values_ and table_name_ for inserts into a statement
#and executes it; not it populates @id after the fact
def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end









#------------------------------------------------------------------------
#class

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  DB[:conn].execute(sql)
end


#eoc
end



