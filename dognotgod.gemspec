# This gemspec builds a single gem for both the server and the client. What this means
# is that, even though you may only need the client on the machines you are monitoring, 
# you will get all the server specific dependencies.
#
# If you would like a clean client gem, use dognotgod-client.gemspec to build it
Gem::Specification.new do |s|
   s.name = %q{dognotgod}
   s.version = "0.1.3"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a performance monitoring tool.}
   s.homepage = %q{http://github.com/spoonsix/dognotgod}
   s.description = %q{dog not god is a performance monitoring tool.}
   s.add_dependency("sinatra", ">=0.9.0.4")
   s.add_dependency("sequel", ">=2.10.0")
   s.add_dependency("haml", ">=2.0.7")
   s.add_dependency("thin", ">=1.0.0")
   s.add_dependency("sqlite3-ruby", ">=1.2.4")
   s.add_dependency("rest-client", ">=0.9")
   
   # s.files = ["app/**/*", "config.ru", "README.md", "public/*", "views/*", "config/*", "server.rb", "client.rb"].map { |d| Dir[d] }.flatten
   s.files = ["app/models", "app/models/disk.rb", "app/models/file_system.rb", "app/models/host.rb", "app/models/load.rb", "app/models/memory.rb", "config.ru", "README.md", "views/layout.haml", "views/main.haml", "views/style.sass", "config/thin.yml", "server.rb", "client.rb"]
   s.executables = ["dognotgod", "dognotgod-client"]
end
