Gem::Specification.new do |s|
   s.name = %q{dognotgod-client}
   s.version = "0.1.9"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a server health monitoring tool.}
   s.description = %q{dog not god is a server health monitoring tool.}
   s.homepage = %q{http://github.com/spoonsix/dognotgod}
   s.add_dependency("rest-client", ">=0.9")
   
   s.files = ["client.rb", "bin/dognotgod-client", "lib/base.rb", "lib/client_commands.rb"]   
   s.executables = ["dognotgod-client"]
end

