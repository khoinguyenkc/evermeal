require 'bundler'

Bundler.require



ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/development.sqlite"
)
#apparently its development.sqlite3. i had sqlite and it didn't work
#i tried this because i saw the labs had it as sqlite3
#how come avi's video had it as .sqlite and it wstill worked?
#he also used sqlite3 in his gemfile, but he didn't put '~>1.3.6' like i did...
#this stuff is crazy. its like searching in the blind
#the development.sqlite isn't there. i think it will rate when stuff runs

require_all 'app'
#tried changing to ./app or ../app. doesnt fix the unexpected tFloat tInteger problem


#speculation: how everything is hooked up
#outermost is the config.ru, connects to environment file
#environment files connects to app folder with require_all 'app'
#environment files connects to db with activerecord base estab connection
#environment files connects to gemfile and gemfile.lock with bundler stuff (totally guessing)
#the only thing thats not connected is rakefile
