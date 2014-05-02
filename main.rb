$:.unshift "."
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/flash'
require 'pl0_program'
require 'auth'
require 'pp'

enable :sessions
set :session_secret, '*&(^#234)'
set :reserved_words, %w{grammar test login auth}
set :max_files, 3        # no more than max_files+1 will be saved

helpers do
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? 'class = "current"' : ''
  end
end

get '/grammar' do
  erb :grammar
end

get '/test' do
  erb :test
end

get '/:selected?' do |selected|
  puts "*************@auth*****************"
  puts session[:name]
  pp session[:auth]
  programs = Program.all
  pp programs
  puts "selected = #{selected}"
  c  = Program.first(:name => selected)
  source = if c then c.source else "a = 3-2-1" end
  erb :index, 
      :locals => { :programs => programs, :source => source }
end

post '/save' do
  pp params
  name = params[:fname]
  if session[:auth] # authenticated
    if settings.reserved_words.include? name  # check it on the client side
      flash[:notice] = 
        %Q{<div class="error">Can't save file with name '#{name}'.</div>}
      redirect back
    else 
      user = Usuario.first(:username => session[:name]) #buscamos el usuario.
       if !user 
 	redirect to '/'
  	user = Usuario.create(:username => session[:name])
       end
      
      pp user
      
      c  = Program.first(:name => name) #Buscamos programa
      if c
        c.source = params["input"]
        c.save
      else
        if Program.all.size >= settings.max_files
          c = Program.all.sample
          c.destroy
        end
        c = Program.create(
          :name => params["fname"], 
          :source => params["input"])
 	user.pl0program << c  #añadimos el programa a usuario
 	user.save #guardamos el usuario
      end
      flash[:notice] = 
        %Q{<div class="success">File saved as #{c.name} by #{session[:name]}.</div>}
      pp c
      redirect to '/'+name
    end
  else
    flash[:notice] = 
      %Q{<div class="error">You are not authenticated.<br />
         Sign in with Google.
         </div>}
    redirect back
  end
end
