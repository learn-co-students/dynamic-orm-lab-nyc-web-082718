require_relative "../config/environment.rb"
require 'active_support/inflector'

require "pry"

class InteractiveRecord

  def initialize(arg={})
    arg.each do |k, v|
      self.send(("#{k}="), v)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
     column_names << column["name"]
    end

    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name #string
  end

  def cols_minus_id
    self.class.column_names.reject { |c| c == "id" }
  end

  def col_names_for_insert
    cols_minus_id.join(", ") # string
  end

  def values_for_insert
    cols_minus_id.map { |c| "'#{self.send(c)}'" }.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} ( #{col_names_for_insert} ) VALUES ( #{values_for_insert} )"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(args)
    vals = args.map do |k, v|
      if v.class == String
        "#{k} = '#{v}'"
      else
        "#{k} = #{v}"
      end
    end
    str = vals.join(" AND ")

    sql = "SELECT * FROM #{self.table_name} WHERE #{str}"
    # sql = "SELECT * FROM ? WHERE ?"
    # binding.pry

    # DB[:conn].execute(sql, self.table_name, str)
    DB[:conn].execute(sql)

    # binding.pry
  end

end
