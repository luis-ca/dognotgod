require 'rake'

Gem::Specification.new do |s|
   s.name = %q{dognotgod}
   s.version = "0.1.2"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a performance monitoring tool.}
   s.homepage = %q{http://github.com/luiscorreadalmeida/dog}
   s.description = %q{dog not god is a performance monitoring tool.}
   s.files = FileList["app/**/*", "config.ru", "server.rb", "README", "public/*", "views/*", "config/*", "client.rb"]
   s.add_dependency("sinatra", ">=0.9.0.4")
   s.add_dependency("sequel", ">=2.10.0")
   s.add_dependency("haml", ">=2.0.7")
   s.add_dependency("thin", ">=1.0.0")
   s.add_dependency("sqlite3-ruby", ">=1.2.4")
   s.executables = "dognotgod"
end
