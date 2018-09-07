require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end


  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("pragma table_info('#{table_name}')")
    table_info.map do |column|
      column['name']
    end.compact
  end


  def initialize(h={})
    h.each do |property, value|
      self.send("#{property}=", value)
    end
  end


  def table_name_for_insert
    self.class.table_name
  end


  def col_names_for_insert
    cols = self.class.column_names
    cols.delete('id')
    cols.join(', ')
  end


  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      value = self.send(col_name)
      values << "'#{value}'" unless self.send(col_name).nil?
    end
    values.join(', ')
  end

  def save
    sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end


  def self.find_by(attribute)
    if attribute.values[0].is_a? Integer
      value = attribute.values[0]
    else
      value = "#{attribute.values[0]}"
    end
      sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = #{attribute.values[0]}"
    else
      sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = '#{attribute.values[0]}'"
    end
    d = DB[:conn].execute(sql)
    # binding.pry
  end

end # end InteractiveRecord class
