Gem::Specification.new do |s|
   s.name = %q{dognotgod-client}
   s.version = "0.1.6"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a performance monitoring tool.}
   s.homepage = %q{http://github.com/spoonsix/dognotgod}
   s.description = %q{dog not god is a performance monitoring tool.}
   s.add_dependency("rest-client", ">=0.9")
   
   s.files = ["client.rb", "bin/dognotgod-client"]   
   s.executables = ["dognotgod-client"]
end
