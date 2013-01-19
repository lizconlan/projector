require 'sinatra'
require 'active_record'
require 'haml'

before do
  dbconfig = YAML::load(File.open 'config/database.yml')
  ActiveRecord::Base.establish_connection(dbconfig)
  @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
end

require './models/project'
require './models/repository'
require './models/live_site'

get "/" do
  @projects = Projects.all #ok, should paginate here but this will do for now
  haml(:index)
end

get "/project/:id" do
  @project = Project.find(id)
  haml(:show)
end

get "/project/:id/edit" do
end

get "/project/:id/delete" do
end

get "/create" do
  
end