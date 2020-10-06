#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'Blog.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "content" TEXT
    )'

  @db.execute 'CREATE TABLE IF NOT EXISTS "Comments"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "created_date" DATE,
      "content" TEXT,
      "post_id" INTEGER
    )'
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY ID DESC'

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  if content.length == 0
    @error = 'Type post text'
    return erb :new
  end

  @db.execute 'INSERT INTO Posts (content, created_date) VALUES(?, datetime())', [content]

  redirect to '/'
end

get '/post/:id' do
  # Получение параметра из URL
  id = params[:id]

  results = @db.execute 'SELECT * FROM Posts WHERE ID = ?', [id]
  @row = results[0]

  erb :post
end

post '/post/:id' do
  id = params[:id]
  content = params[:content]

  @db.execute 'INSERT INTO Comments (content, created_date, post_id) VALUES(?, datetime(), ?)', [content, id]

  redirect to ('/post/' + id)
end