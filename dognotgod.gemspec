require 'rake'

Gem::Specification.new do |s|
   s.name = %q{dognotgod}
   s.version = "0.1.1"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a performance monitoring tool.}
   s.homepage = %q{http://github.com/luiscorreadalmeida/dog}
   s.description = %q{dog not god is a performance monitoring tool.}
   s.files = FileList["app/**/*", "config.ru", "server.rb", "README", "public/*", "views/*", "config/*", "client.rb"]
end