require 'rubygems'
require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/project.db")
class Project
	include DataMapper::Resource
	property :id, Serial
	property :organisation, Text
	property :project_name, Text
	property :sector, Text
	property :country, Text
	property :rating, Text
	property :description, Text
	property :summary, Text
	property :funding_goal, Text
	property :current_funding, Text
	property :funding_date, Text
	property :created_at, DateTime
	property :updated_at, DateTime
	property :status, Text
end
DataMapper.finalize.auto_upgrade!


get '/' do
	@project = Project.all(:limit => 4,  :order => :id.desc)
	@title = 'Home'
	erb :home , :layout => :index
end 


post '/' do
	r = Project.new
	r.project_name = params[:project_name]
	r.organisation = params[:organisation]
	r.sector = params[:sector]
	r.country = params[:country]
	r.rating = params[:rating]
	r.description = params[:description]
	r.summary = params[:summary]
	r.funding_goal = params[:funding_goal]
	r.funding_date = params[:funding_date]
	r.status = params[:status]
	r.created_at = Time.now
	r.updated_at = Time.now
    r.save
	redirect '/'
end

# Used to filter all project by sector
get '/agriculture' do
	@project = Project.all(:sector => 'Agriculture')
	@title = 'Agriculture'
	erb :home
end

get '/economic_development' do
	@project = Project.all(:sector => 'Economic Development')
	@title = 'Economic Development'
	erb :home
end

get '/education' do
	@project = Project.all(:sector => 'Education')
	@title = 'Education'
	erb :home
end

get '/environment_naturalresources' do
	@project = Project.all(:sector => 'Environment & Natural Resources')
	@title = 'Environment & Natural Resources'
	erb :home
end

get '/finance' do
	@project = Project.all(:sector => 'Finance & Financial Reform')
	@title = 'Finance & Financial Reform'
	erb :home
end

get '/governance' do
	@project = Project.all(:sector => 'Governance')
	@title = 'Governance'
	erb :home
end

get '/health' do
	@project = Project.all(:sector => 'Health')
	@title = 'Health'
	erb :home
end

get '/rural_development' do
	@project = Project.all(:sector => 'Rural Development')
	@title = 'Rural Development'
	erb :home
end

get '/social_development' do
	@project = Project.all(:sector => 'Social Development')
	@title = 'Social Development'
	erb :home
end

get '/tourism' do
	@project = Project.all(:sector => 'Tourism')
	@title = 'Tourism'
	erb :home
end

get '/other' do
	@project = Project.all(:sector => 'Other')
	@title = 'Other'
	erb :home
end


get '/add' do
  @title = "Create project #{params[:id]}"  
  erb :add  
end

get '/:id' do  
  @project = Project.get params[:id]  
  @title = "Edit project #{params[:id]}"  
  erb :edit  
end  

def save s
  unless s.save
    s.errors.each { |e| puts e }
    raise 'Error saving item'
  end
end

put '/:id' do
	r = Project.get params[:id]
	r.project_name = params[:project_name]
	r.organisation = params[:organisation]
	r.sector = params[:sector]
	r.country = params[:country]
	r.rating = params[:rating]
	r.description = params[:description]
	r.summary = params[:summary]
	r.funding_goal = params[:funding_goal]
	r.current_funding = params[:current_funding]
	r.funding_date = params[:funding_date]
	r.status = params[:status]
	r.updated_at = Time.now
	 save r
	redirect '/'
end

get '/:id/delete' do
	@project = Project.get params[:id]
	@title = "Confirm deletion of project #{params[:id]}"
	erb :delete
end

delete '/:id' do
	n = Project.get params[:id]
	n.destroy
	redirect '/'
end

get '/:id/display' do
	@project = Project.get params[:id]
	@title = "Project for #{params[:id]}"
	erb :display
end
