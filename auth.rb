require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-twitter'
require 'omniauth-facebook'

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
  provider :twitter, 'aSmqMi3pt2TgrAc7Ap2mM7CEt', '0HnQWVrFLWSOt5FESRS455P4mxrtY4fb9cRAwM2K3ndu5DDPmu'
  provider :facebook, '696574380401495', '9fbeb5ea8715702a2ba71581fc840e23'
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
  puts "pepe"
  flash[:notice] = 
        %Q{<div class="success">Authenticated as #{@auth['info'].name}.</div>}
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] 
  redirect '/'
end
