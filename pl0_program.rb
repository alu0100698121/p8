require 'data_mapper'
# full path!
DataMapper.setup(:default, 
                 ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db" )


class Usuario
   include DataMapper::Resource
   
   property :id,     Serial
   property :username, String, :key => true
   has n, :programs
end

class Program
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :source, String, :length => 1..1024
  
  belongs_to :usuario, :required => false
end

DataMapper.finalize
DataMapper.auto_migrate!
DataMapper.auto_upgrade!


