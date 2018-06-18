require_relative "../config/environment.rb"
require_relative "./modules/databaseable.rb"
require 'active_support/inflector'

class Song

  extend Databaseable::ClassMethods
  include Databaseable::InstanceMethods


  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end


end
