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

get '/' do
   todos_usuarios = Usuario.all
   programas = []
   
   source = "a = 3-2-1."
   erb :index,:locals => { :programs => programas, :source => source, :user => todos_usuarios }
   
end

get '/:usuario?' do usuario
   var user =  Usuario.first(:username => usuario)
   pp user
   if(!user)
     flash[:notice] = 
        %Q{<div class="error">El usuario #{usuario} no está creado</div>}
     redirect to '/'
   end 
   
  programas = user.programs
  source = ""

  erb :index, :locals => { :programs => programas, :source => source, :user => user.username}
end

get '/:usuario?:/programa?' do |usuario,programa|
   var user =  Usuario.first(:username => usuario)
   pp user
   if(!user)
     flash[:notice] = 
        %Q{<div class="error">El usuario #{usuario} no está creado</div>}
     redirect to '/'
   end 
   
   var program = user.programs.first(:name =>programa)
   if(!program)
	flash[:notice] = 
        %Q{<div class="error">El programa #{programa} no está creado</div>}
     redirect to '/'
   end 
   
    erb :index, 
      :locals => { :programs => user.programs, :source => program.source}
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
  flash[:notice] = 
        %Q{<div class="Entro en save"</div>}
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
 	user = Usuario.create(:username => session[:name])
       end
      
      pp user
      
      c  = user.programs.first(:name => name) #Buscamos programa
      if c
        c.source = params["input"]
        c.save
      else
        if user.programs.all.size >= settings.max_files
          c = user.programs.all.sample
          c.destroy
        end
        c = Program.create(
          :name => params["fname"], 
          :source => params["input"])
 	user.programs << c  #añadimos el programa a usuario
 	user.save #guardamos el usuario
      end
      flash[:notice] = 
        %Q{<div class="success">File saved as #{c.name} by #{session[:name]}.</div>}
      pp c
      post user.username
      redirect to '/'#+ user.username +'/'+ name
    end
  else
    flash[:notice] = 
      %Q{<div class="error">You are not authenticated.<br />
         Sign in with Google.
         </div>}
    redirect back
  end
end
