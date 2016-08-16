require_relative 'searchable'
require_relative 'association_options'
require 'active_support/inflector'

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      options
        .model_class
        .where(options.primary_key => self.send(options.foreign_key))
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      options
        .model_class
        .where(options.foreign_key => self.send(options.primary_key))
    end
  end

  def has_one_through(name, through, source)
    define_method(name) do
      through_options = self.class.assoc_options[through]
      source_options = through_options.model_class.assoc_options[source]

      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key

      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      results = DBConnection.execute(<<-SQL, self.send(through_foreign_key))
        SELECT
          #{source_table}.*
        FROM
          #{source_table}, #{through_table}
        WHERE
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        AND
          #{through_table}.#{through_primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
