# dog not god: server health monitoring simplified

dog not god is a server health monitoring tool for *nix based servers. The focus is on simplicity and on a 100% ruby implementation.

### Installation

    gem sources -a http://gems.github.com
    sudo gem install spoonsix-dognotgod
    sudo gem install spoonsix-dognotgod-client

### Server
The server captures performance data, and presents it via a web based interface.

    dognotgod start

This will kick off a thin server on port 4567. It will also create the folder ~/.dognotgod and store the SQLite database at this location.

### Client

The client sits on the target machine - the machine to be monitored - captures performance data and sends it to the server. Note that this works on the machine acting as the server as well.

    crontab -e
    */1 * * * * /path/to/dognotgod-client -a server-address -p port >> /dev/null 2>&1

This will run the client every minute. By default, the server-address is 127.0.0.1 and the port is 4567.

## License

dog not god: server health monitoring simplified
Copyright (C) 2009 spoonsix - Luis Correa d'Almeida

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
