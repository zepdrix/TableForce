# TableForce
---
TableForce executes SQL queries so you don't have to. It is a lightweight tool inspired by Active Record that provides Object Relational Mapping in an easy to use format, allowing for minimal configuration.

## What can TableForce do for me?
---
TableForce provides a SQLObject class that interacts with a database (a demo SQLite database is included in this repo)

Built-in methods include:
 - `::all` => returns an array of Ruby objects of all records in a table
 - `::find` => looks up a record by its primary key, returns the object if it exists
 - `::where` => performs a SQL query with a params argument, prevents SQL injection attacks
 - `::belongs_to` => builds a method that describes a relationship with a given association name and an options hash
 - `::has_many` => builds a method that describes a relationship with a given association name and an options hash
 - `::has_one_through` => builds a method that describes a relationship which traverses a join table with a given name, the 'through' model name, and the 'source' model name
 - `::has_many_through` => builds a method that describes a many to many relationship which traverses a join table with a given name, the 'through' model name, and the 'source' model name
 - `#insert` => inserts a new row into the table
 - `#update` => updates an existing row in the table with given params
 - `#save` => a 'convenience' method that calls either calls update (if the SQLObject exists in the table) or insert (if the SQLObject is new)

## TableForce looks great, how can I use it?
---
First, clone this repo. A demo .sql file is provided for you. If you want to use your own, just replace the paths in `lib/db_connection.rb` and make your own database. Remember to require `sql_object` and `associatable`.

```Ruby
#model.rb

require_relative "../lib/sql_object"
require_relative "../lib/associatable"

class Guitar > SQLObject
  finalize!
  # finalize! is a method in SQLObject that sets attributes and their values.
end
```

Using irb/pry, you can load the file and access the methods.

```bash
[1] pry(main)> load "model/model.rb"
=> true
[2] pry(main)> Guitar.all
=> [#<Guitar:0x007fec633dcde8 @attributes={:id=>1, :name=>"Gretsch 62", :guitarist_id=>1}>,
 #<Guitar:0x007fec633dcbb8 @attributes={:id=>2, :name=>"Rickenbacker 325", :guitarist_id=>2}>,
 #<Guitar:0x007fec633dc988 @attributes={:id=>3, :name=>"ESP KH-602", :guitarist_id=>3}>,
 #<Guitar:0x007fec633dc758 @attributes={:id=>4, :name=>"ESP LTD", :guitarist_id=>4}>,
 #<Guitar:0x007fec633dc528 @attributes={:id=>5, :name=>"Epiphone Casino", :guitarist_id=>2}>,
 #<Guitar:0x007fec633dc2f8 @attributes={:id=>6, :name=>"Fender Stratocaster", :guitarist_id=>6}>]
[3] pry(main)> Guitar.all.first.attributes
=> {:id=>1, :name=>"Gretsch 62", :guitarist_id=>1}
[4] pry(main)> Guitar.find(6)
=> #<Guitar:0x007fec651a2fd0 @attributes={:id=>6, :name=>"Fender Stratocaster", :guitarist_id=>6}>
[5] pry(main)> Guitar.where(guitarist_id: 2)
=> [#<Guitar:0x007fec62ed6bf0 @attributes={:id=>2, :name=>"Rickenbacker 325", :guitarist_id=>2}>,
 #<Guitar:0x007fec62ed69c0 @attributes={:id=>5, :name=>"Epiphone Casino", :guitarist_id=>2}>]

```

If you create multiple models and define associations, you will be able to use the association methods. In the following example, since the tables used in the example have columns that follow naming convention, TableForce is able to create associations without requiring foreign key, primary key, or class names.


NB: finalize! is a method that TableForce relies on to set up the relationships, you will need to include the finalize! method call if you use your own classes.

```Ruby
#model.rb

require_relative "../lib/sql_object"
require_relative "../lib/associatable"

class Guitar > SQLObject
  finalize!

  belongs_to :guitarist
  has_one_through :band, :guitarist, :band

  #The new association defined here is band, which traverses the through association,
  #:guitarist, to the source association, :band. The through and source associations
  #both need to exist in order to define this association.
end

class Guitarist < SQLObject
  finalize!

  belongs_to :band
  has_many :guitars
end

class Band < SQLObject
  finalize!

  has_many :guitarists
  has_many_through :guitars, :guitarists, :guitars

  #The new association defined here is guitars, which traverses the through association,
  #:guitarists, to the source association, :guitars. The through and source associations
  #both need to exist in order to define this association.
end
```

Class methods that define associations between tables take in existing associations as arguments and runs SQL queries based on existing table definitions. Here's an example of an association method, the has_many_through method.

```Ruby
def has_many_through(name, through, source)
  define_method(name) do
    through_options = self.class.assoc_options[through]
    source_options = through_options.model_class.assoc_options[source]

    through_table = through_options.table_name
    through_primary_key = through_options.primary_key
    through_foreign_key = through_options.foreign_key

    source_table = source_options.table_name
    source_primary_key = source_options.primary_key
    source_foreign_key = source_options.foreign_key

    #Define table names and keys

    table_name = self.class.table_name

    results = DBConnection.execute(<<-SQL, self.id)
      SELECT
        #{source_table}.*
      FROM
        #{source_table}, #{through_table}, #{table_name}
      WHERE
        #{through_table}.#{source_primary_key} = #{source_table}.#{source_foreign_key}
      AND
        #{table_name}.id = #{through_table}.#{through_foreign_key}
      AND
        #{table_name}.id = ?
      ORDER BY
        #{source_table}.#{source_primary_key}
    SQL

    #Run query based on existing associations

    source_options.model_class.parse_all(results)
  end
end
```

If the primary_key, foreign_key, or class_name fall outside of naming convention or if you want to specify them in the code, simply pass them in as an options hash at the method call.

```Ruby

class Record < SQLObject
  finalize!

  has_many :guitarists, primary_key: :id, foreign_key: :album_id, class_name: 'Guitarist'
end

```

As you can see, the has_many, belongs_to, and has_one_through methods have defined relationships between the models.

```bash
[1] pry(main)> load 'model/model.rb'
=> true
[2] pry(main)> Guitar.all.first
=> #<Guitar:0x007f8a9340de70 @attributes={:id=>1, :name=>"Gretsch 62", :guitarist_id=>1}>
[3] pry(main)> Guitar.all.first.guitarist
=> #<Guitarist:0x007f8a9340c138 @attributes={:id=>1, :fname=>"George", :lname=>"Harrison", :band_id=>1}>
[4] pry(main)> Guitar.all.first.band
=> #<Band:0x007f8a93c16b80 @attributes={:id=>1, :name=>"The Beatles"}>
[5] pry(main)> Guitarist.find(2).guitars
=> [#<Guitar:0x007f8a92e6fec8 @attributes={:id=>2, :name=>"Rickenbacker 325", :guitarist_id=>2}>,
 #<Guitar:0x007f8a92e6fc20 @attributes={:id=>5, :name=>"Epiphone Casino", :guitarist_id=>2}>]

```
