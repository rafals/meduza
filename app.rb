require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'meduza'
DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/database.db")
DataMapper.auto_upgrade!

set :sessions,  true
set :environment, :production

def play
  @@cron = Thread.new do
    loop do
      puts "\n" + Time.now.to_s + ":"
      (
      Meduza.all(:in_torpor => false).each do |m|
        puts m.name.to_s + " => g: " + m.hungry.to_s + ", p: " + m.thirsty.to_s + ", n: " + m.bored.to_s + ", ch: " + m.sick.to_s + ", t: " + m.in_torpor.to_s
        m.live
        puts m.name.to_s + " => g: " + m.hungry.to_s + ", p: " + m.thirsty.to_s + ", n: " + m.bored.to_s + ", ch: " + m.sick.to_s + ", t: " + m.in_torpor.to_s
        m.save
      end
      )
      sleep 60
    end
  end
end

play()

def kill
  Thread.kill(@@cron)
  puts "!" * 10 + " Cron Killed " + "!" * 10
end

def get_med
  (session[:id] and (@meduza = Meduza.get session[:id])) or halt 500
end

get '/' do
  if session[:id]
    unless @meduza = Meduza.get(session[:id])
      halt 300
    end
  else
    if @meduza = Meduza.first
      session[:id] = @meduza.id
    else
      halt 300
    end
  end
  haml @meduza.in_torpor ? :dead : :show
end

get '/new/:name' do
  m = Meduza.new(:name => params[:name])
  m.save
  session[:id] = m.id
  redirect '/'
end

get '/daj_jesc' do
  @meduza = Meduza.get!(session[:id])
  puts @meduza.hungry
  @meduza.daj_jesc
  puts @meduza.hungry
  @meduza.save
  redirect '/'
end

get '/daj_pic' do
  @meduza = Meduza.get!(session[:id])
  puts @meduza.thirsty
  @meduza.daj_pic
  puts @meduza.thirsty
  @meduza.save
  redirect '/'
end

get '/pobaw_sie' do
  @meduza = Meduza.get!(session[:id])
  puts @meduza.bored
  @meduza.pobaw_sie
  puts @meduza.bored
  @meduza.save!
  redirect '/'
end

get '/:name' do
  if m = Meduza.first(:name => params[:name])
    session[:id] = m.id
    redirect '/'
  else
    pass
  end
end

get '/:id' do
  if meduza = Meduza.get(params[:id])
    session[:id] = params[:id]
    redirect '/'
  else
    @error = "Nie ma meduzy o id " + params[:id] + ". :<"
    haml :error
  end
end