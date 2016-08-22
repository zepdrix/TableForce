require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where = params.keys.map do |key|
      key.to_s + " = ?"
    end.join(' AND ')

    search_values = params.values

    results = DBConnection.execute(<<-SQL, *search_values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where}
    SQL

    parse_all(results)
  end
end
