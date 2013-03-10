require 'sinatra'
require 'sinatra/flash'
require 'active_record'
require 'haml'
require 'redcarpet'

enable :sessions

before do
  dbconfig = YAML::load(File.open 'config/database.yml')
  ActiveRecord::Base.establish_connection(dbconfig)
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
end

helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate_user!
    redirect "/login" unless current_user
  end
end

require './models/project'
require './models/repository'
require './models/live_site'
require './models/user'

get "/" do
  @projects = Project.find(:all, :order => "date desc") #ok, should paginate here but this will do for now
  haml(:index)
end

get "/login/?" do
  haml :login
end

post "/login" do
  user = User.find_by_login(params[:login])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    flash.next[:success] =  "You're logged in. Welcome back"
    flash.keep
    redirect '/'
  else
    flash.now[:alert] = "Login didn't work. Try again?"
    haml :login
  end
end

get '/logout/?' do
  session[:user_id] = nil
  flash.next[:success] =  "You've logged out"
  redirect '/'
end

get "/add/?" do
  authenticate_user!
  @project = Project.new
  haml(:edit)
end

post "/add/?" do
  authenticate_user!
  # needs to do error checking and jump back to/redisplay the error form if there's a problem
  # i.e. - slug not unique, invalid date
  
  @project = Project.new
  @project.name = params[:name]
  @project.slug = params[:slug]
  @project.date = params[:date]
  @project.readme = params[:readme]
  @project.save
  
  redirect("/#{@project.slug}")
end

get "/:slug/edit/?" do
  authenticate_user!
  @project = Project.find_by_slug(params[:slug])
  haml(:edit)
end

post "/:slug/edit/?" do
  authenticate_user!
  # needs to do error checking and jump back to/redisplay the error form if there's a problem
  # i.e. - slug not unique, invalid date
  
  @project = Project.find_by_slug(params[:slug])
  @project.name = params[:name]
  @project.slug = params[:slug]
  @project.date = params[:date]
  @project.readme = params[:readme]
  @project.save
  
  redirect("/#{@project.slug}")
end

get "/:slug/delete/?" do
  :authenticate_user!
end

get "/:slug/?" do
  @project = Project.find_by_slug(params[:slug])
  haml(:show)
end