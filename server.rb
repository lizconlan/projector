require 'sinatra'
require 'sinatra/flash'
require 'active_record'
require 'haml'
require 'date'
require 'redcarpet'

enable :sessions

before do
  env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
  dbconfig = YAML::load(File.open 'config/database.yml')[env]
  @title = if ENV['title'] ? ENV['title'] ? YAML::load(File.open 'config/site.yml')[:title]
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
  
  def invalid_slugs
    ["add", "edit", "new", "create", "delete", "login", "logout"]
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
  @project.slug = params[:slug].downcase
  @project.date = params[:date]
  @project.readme = params[:readme]
  
  if Project.find_by_slug(params[:slug])
    flash.now[:alert] = "Slug aleady in use, needs to be unique"
    @error_field = "slug"
    haml(:edit)
  elsif invalid_slugs.include?(params[:slug]) or params[:slug].include?("/")
    flash.now[:alert] = "Invalid slug, pick another"
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
  @project.slug = params[:slug].downcase
  @project.date = params[:date]
  @project.readme = params[:readme]
  
  if params[:slug] != params[:original_slug] and Project.find_by_slug(params[:slug])
    flash.now[:alert] = "Slug aleady in use, needs to be unique"
    @error_field = "slug"
    haml(:edit)
  elsif invalid_slugs.include?(params[:slug]) or params[:slug].include?("/")
    flash.now[:alert] = "Invalid slug, pick another"
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
  authenticate_user!
  
  @project = Project.find_by_slug(params[:slug])
  haml(:project_delete)
end

post "/:slug/delete" do
  authenticate_user!
  
  if params[:submit] == "Yes"
    project = Project.find_by_slug(params[:slug])
    project.delete
  end
  redirect("/#{params[:slug]}")
end

get "/:slug/repo_:id/edit/?" do
  authenticate_user!
  
  @repo = Repository.find(params[:id])
  @repo.notes.gsub!("\n", "")
  haml(:repo_edit)
end

post "/:slug/repo_:id/edit" do
  authenticate_user!
  
  @repo = Repository.find(params[:id])
  
  @repo.name = params[:name]
  @repo.url = params[:link]
  @repo.notes = params[:notes]
  
  @repo.save
  redirect("/#{params[:slug]}/edit")
end

get "/:slug/repo/add/?" do
  authenticate_user!
  
  @repo = Repository.new
  haml(:repo_edit)
end

post "/:slug/repo/add" do
  authenticate_user!
  
  project = Project.find_by_slug(params[:slug])
  
  @repo = Repository.new
  @repo.name = params[:name]
  @repo.url = params[:link]
  @repo.notes = params[:notes]
  @repo.project_id = project.id
  
  @repo.save
  redirect("/#{params[:slug]}/edit")
end

get "/:slug/repo_:id/delete/?" do
  authenticate_user!
  
  @repo = Repository.find(params[:id])
  haml(:repo_delete)
end

post "/:slug/repo_:id/delete" do
  authenticate_user!
  
  if params[:submit] == "Yes"
    repo = Repository.find(params[:id])
    repo.delete
  end
  redirect("/#{params[:slug]}/edit")
end

get "/:slug/site_:id/edit/?" do
  authenticate_user!
  
  @site = LiveSite.find(params[:id])
  @site.notes.gsub!("\n", "")
  haml(:site_edit)
end

post "/:slug/site_:id/edit" do
  authenticate_user!
  
  @site = LiveSite.find(params[:id])
  @site.url = params[:link]
  @site.notes = params[:notes]
  
  @site.save
  redirect("/#{params[:slug]}/edit")
end

get "/:slug/site_:id/delete/?" do
  authenticate_user!
  
  @site = LiveSite.find(params[:id])
  haml(:site_delete)
end

post "/:slug/site_:id/delete" do
  authenticate_user!
  
  if params[:submit] == "Yes"
    site = LiveSite.find(params[:id])
    site.delete
  end
  redirect("/#{params[:slug]}/edit")
end

get "/:slug/?" do
  @project = Project.find_by_slug(params[:slug])
  haml(:show)
end