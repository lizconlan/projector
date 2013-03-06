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
  @projects = Project.all #ok, should paginate here but this will do for now
  haml(:index)
end

get "/:slug/edit/?" do
  @project = Project.find_by_slug(params[:slug])
  haml(:edit)
end

post "/:slug/edit/?" do
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

get "/add/?" do
end

post "/add/?" do
end