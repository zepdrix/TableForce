require_relative '../lib/sql_object'
require_relative '../lib/associatable'

class Guitar < SQLObject
  finalize!

  belongs_to :guitarist
  has_one_through :band, :guitarist, :band
end

class Guitarist < SQLObject
  finalize!

  belongs_to :band
  has_many :guitars
end

class Band < SQLObject
  finalize!

  has_many :guitarists
end
