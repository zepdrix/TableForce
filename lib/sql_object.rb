require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns

    col_arr = DBConnection.execute2(<<-SQL).first.map do |key|
      SELECT
        *
      FROM
        #{table_name}
      LIMIT
        0
    SQL
      key.to_sym
    end
    @columns = col_arr
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method(col.to_s + '=') do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  def self.all
    all_rows = []

    DBConnection.execute2("SELECT * FROM " + table_name).map do |el|
      all_rows << self.new(el) if el.is_a?(Hash)
    end
    all_rows

  end

  def self.parse_all(results)
    result_arr = []
    results.each do |item|
      a = self.new(item)
      result_arr << a
    end
    result_arr
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
      LIMIT
        1
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |key, val|
      if respond_to?(key.to_s + '=')
        send(key.to_s + '=', val)
      else
        raise Exception.new("unknown attribute '#{key}'")
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    arr = []
    self.class.columns.each do |key, val|
      arr << attributes[key]
    end
    arr
  end

  def insert
    cols = self.class.columns.join(', ')
    vals = ["?"] * self.class.columns.length
    vals = vals.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{cols})
    VALUES
      (#{vals})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    setters = self.class.columns.map do |col|
      col.to_s + " = ?"
    end.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{setters}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    self.class.find(self.id) ? update : insert
  end

  extend Associatable
  extend Searchable
end
