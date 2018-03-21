require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
  db.execute('select * from Barbers where name=?', [name]).length > 0
end


def seed_db db, barbers
    barbers.each do |barber|
      if !is_barber_exists? db, barber
        db.execute 'insert into Barbers (name) values (?)', [barber]
      end
    end
end

def get_db
  return SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end


before do
  db = get_db
  @barbers = db.execute 'select * from Barbers'
end

configure do
 db = get_db

db.execute 'CREATE TABLE IF NOT EXISTS
              "Users"
   (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "username" TEXT,
     "phone" TEXT,
  "datestamp" TEXT,
   "barber" TEXT,
   "color" TEXT
 )'


 db.execute 'CREATE TABLE IF NOT EXISTS
              "Barbers"
   (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "name" TEXT
 )'

seed_db db, ['Jessie Pikman', 'Walter White', 'Gus Fring', 'Mike']
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret!!</a>?'
end

get '/login/form' do
  erb :login_form
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

get '/contact' do
  erb :contact
end


post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]




  hh = {
      :username => "Your name",
      :phone => "Your phone",
      :datetime => "Data"
  }

  @error = hh.select{|key,_| params[key] == ""}.values.join(", ")

   if @error != ""
     return erb :visit
   end

db = get_db
  db.execute 'insert into
             Users
(
username,
phone,
datestamp,
barber,
color
)
values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]



  erb "</br><h2>Success!</h2>"
end











post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end


get '/contact' do
  "Hello World"
end

get '/showusers' do
  db = get_db

  @results = db.execute 'select * from Users order by id desc'


  erb :showusers
end