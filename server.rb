require 'sinatra'
require 'sinatra/flash'
require 'active_record'
require 'haml'
require 'date'
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
  
  @project = Project.new
  @project.name = params[:name]
  @project.slug = params[:slug]
  @project.date = params[:date]
  @project.readme = params[:readme]
  
  if Project.find_by_slug(params[:slug])
    flash.now[:alert] = "Slug aleady in use, needs to be unique"
    @error_field = "slug"
    haml(:edit)
  else
    begin
      Date.parse(@project.date)
    rescue
      flash.now[:alert] = "Invalid date, please correct it before continuing"
      @error_field = "date"
      haml(:edit)
    else
      @project.save
      redirect("/#{@project.slug}")
    end
  end
end

get "/:slug/edit/?" do
  authenticate_user!
  @project = Project.find_by_slug(params[:slug])
  @project.readme.gsub!("\n", "")
  haml(:edit)
end

post "/:original_slug/edit/?" do
  authenticate_user!
  
  @project = Project.find_by_slug(params[:original_slug])
  @project.name = params[:name]
  @project.slug = params[:slug]
  @project.date = params[:date]
  @project.readme = params[:readme]
  
  if params[:slug] != params[:original_slug] and Project.find_by_slug(params[:slug])
    flash.now[:alert] = "Slug aleady in use, needs to be unique"
    @error_field = "slug"
    haml(:edit)
  else
    begin
      Date.parse(@project.date.to_s.split[0])
    rescue
      flash.now[:alert] = "Invalid date, please correct it before continuing"
      @error_field = "date"
      haml(:edit)
    else
      @project.save
      redirect("/#{@project.slug}")
    end
  end
end

get "/:slug/delete/?" do
  :authenticate_user!
end

get "/:slug/?" do
  @project = Project.find_by_slug(params[:slug])
  haml(:show)
end