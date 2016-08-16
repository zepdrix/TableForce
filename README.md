# TableForce
---
TableForce executes SQL queries so you don't have to. It is a lightweight tool that provides Object Relational Mapping in an easy to use format, allowing for minimal configuration.

## What can TableForce do for me?
---
TableForce provides a SQLObject class that interacts with a database (a demo SQLite database is included in this repo)

Built-in methods include:
 - `all` => returns an array of all database records
 - `find` => looks up a record by its primary key
 - `insert` => inserts a new row into the table
 - `update` => updates an existing row in the table with given params
 - `save` => a 'convenience' method that calls either calls update (if the SQLObject exists in the table) or insert (if the SQLObject is new)
 - `where` =>
 - `belongs_to` =>
 - `has-many` =>
 - `has_one_through` =>

## TableForce looks great, how can I use it?
---
First, clone this repo. A demo .sql file is provided for you. If you want to use your own, just replace the paths in `lib/db_connection.rb` and make your own database. Remember to require `sql_object` and `associatable`.

```ruby
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