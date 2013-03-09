require 'sinatra'
require 'active_record'
require 'haml'
require 'redcarpet'

before do
  dbconfig = YAML::load(File.open 'config/database.yml')
  ActiveRecord::Base.establish_connection(dbconfig)
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
end

require './models/project'
require './models/repository'
require './models/live_site'

get "/" do
  @projects = Project.find(:all, :order => "date desc") #ok, should paginate here but this will do for now
  haml(:index)
end

get "/add/?" do
  @project = Project.new
  haml(:edit)
end

post "/add/?" do
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
  @project = Project.find_by_slug(params[:slug])
  haml(:edit)
end

post "/:slug/edit/?" do
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
end

get "/:slug/?" do
  @project = Project.find_by_slug(params[:slug])
  haml(:show)
end