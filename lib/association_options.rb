require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.to_s.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    defaults = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
    }

    @foreign_key = options[:foreign_key] || defaults[:foreign_key]
    @primary_key = options[:primary_key] || defaults[:primary_key]
    @class_name = options[:class_name] || defaults[:class_name]

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    defaults = {
      foreign_key: (self_class_name.to_s.underscore + '_id').to_sym,
      primary_key: :id,
      class_name: name.to_s.singularize.camelcase
    }

    @foreign_key = options[:foreign_key] || defaults[:foreign_key]
    @primary_key = options[:primary_key] || defaults[:primary_key]
    @class_name = options[:class_name] || defaults[:class_name]

  end
end
