require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-twitter'
require 'omniauth-facebook'

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
  provider :twitter, 'CGprHO9zG3nEJNZxXjV79ZdnE', '5EMWLpTCbDuM2j3drpCfw8ZhhFCD7F6IjbSA5Fs2KPD1yaIt5v'
  provider :facebook, '1483847851830273', 'bed2424706ce88afc3b1d080f354cdfe'
end

get '/auth/:provider/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:provider] = @auth['info'].name
  session[:image] = @auth['info'].image
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  #puts "-------------@auth----------------------------------"
  #PP.pp @auth
  #puts "*************@auth.methods*****************"
  #PP.pp @auth.methods.sort
  flash[:notice] = 
        %Q{<div class="success">Authenticated as #{@auth['info'].name}.</div>}
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] 
  redirect '/'
end
