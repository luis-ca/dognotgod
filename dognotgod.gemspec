# This gemspec builds a single gem for both the server and the client. What this means
# is that, even though you may only need the client on the machines you are monitoring, 
# you will get all the server specific dependencies.
#
# If you would like a clean client gem, use dognotgod-client.gemspec to build it
Gem::Specification.new do |s|
   s.name = %q{dognotgod}
   s.version = "0.1.12"
   s.date = Time.now.strftime("%Y-%m-%d")
   s.authors = ["Luis Correa d'Almeida"]
   s.email = %q{luis.ca@gmail.com}
   s.summary = %q{dog not god is a server health monitoring tool.}
   s.description = %q{dog not god is a server health monitoring tool.}
   s.homepage = %q{http://github.com/spoonsix/dognotgod}
   s.add_dependency("sinatra", ">=0.9.0.4")
   s.add_dependency("sequel", ">=2.10.0")
   s.add_dependency("haml", ">=2.0.7")
   s.add_dependency("thin", ">=1.0.0")
   s.add_dependency("sqlite3-ruby", ">=1.2.4")
   s.add_dependency("rest-client", ">=0.9")
   
   # s.files = ["app/**/*", "lib/*", "config.ru", "README.md", "views/*", "config/*", "server.rb", "client.rb", "bin/*", "public/javascripts/*"].map { |d| Dir[d] }.flatten
   s.files = ["app/models", "app/models/disk.rb", "app/models/file_system.rb", "app/models/host.rb", "app/models/load.rb", "app/models/memory.rb", "lib/base.rb", "lib/client_commands.rb", "config.ru", "README.md", "views/host.haml", "views/layout.haml", "views/main.haml", "views/style.sass", "config/thin.yml", "server.rb", "client.rb", "bin/dognotgod", "bin/dognotgod-client", "public/javascripts/jquery.simplemodal-1.2.3.min.js", "public/images/blossom/48x48/world_globe.png", "public/images/coquette/24x24/green_button.png", "public/images/coquette/16x16/green_button.png", "public/images/coquette/24x24/orange_button.png", "public/images/coquette/16x16/orange_button.png", "public/images/coquette/24x24/red_button.png", "public/images/coquette/16x16/red_button.png", "public/images/blossom/32x32/delete_item.png", "public/images/blossom/48x48/user.png", "public/images/blossom/32x32/process.png", "public/images/blossom/32x32/chart.png", "public/images/blossom/32x32/hard_disk.png"]
   s.executables = ["dognotgod", "dognotgod-client"]
end


