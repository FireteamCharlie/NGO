require 'rubygems'
require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/project.db")
class Project
	include DataMapper::Resource
	property :id, Serial
	property :project_name, Text
	property :organisation, Text
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

class Organisation
	include DataMapper::Resource
	property :id, Serial
	property :name, Text
	property :street_address, Text
	property :state, Text
	property :postal_code, Text
	property :country, Text
	property :contact_number, Text
	property :description, Text
	property :credit_check, Boolean, :default  => false
	property :tax_deductability, Boolean, :default  => false
	property :total_staff, Integer
	property :total_countries, Integer
	property :total_donations, Text
end
DataMapper.finalize.auto_upgrade!

get '/about' do
	@title = 'About'
	erb :about
end

get '/admin' do
	@title = 'Admin'
	erb :admin
end

get '/all' do
	@project = Project.all :order => :id.asc
	@title = 'All Projects'
	erb :home
end

get '/' do
	projects = Project.all(:limit => 4,  :order => :id.desc)
	@title = 'Home'
	erb :index , :layout => :layout do
          a = erb :panel, :locals => { :projects => Project.all(:limit => 4, :status =>'Featured',  :order => :id.asc), :header => 'Featured' }
          b = erb :panel, :locals => { :projects => Project.all(:limit => 4, :status =>'Staff Pick', :order => :id.asc), :header => 'Staff Picks' }
          a + b
        end
end 

get '/organisation' do
	@organisation = Organisation.all
	@title = "All Organisations"
	erb :organisations
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

get '/organisation/add' do
  @title = "Create organisation #{params[:id]}"  
  erb :addOrg  
end

post '/organisation' do
	o = Organisation.new
	o.name = params[:name]
    o.save
	redirect '/organisation'
end

get '/organisation/:id' do  
  @organisation = Organisation.get params[:id] 
  @title = "Edit organisation #{params[:name]}"  
  erb :displayOrg  
end  

get '/organisation/:id/edit' do  
  @organisation = Organisation.get params[:id]  
  @title = "Edit organisation #{params[:name]}"  
  erb :editOrg  
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
	r.summary = params[:summary]
	r.description = params[:description]
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

get '/organisation/:id/delete' do
	@organisation = Organisation.get params[:id]
	@title = "Confirm deletion of organisation #{params[:id]}"
	erb :deleteOrg
end

delete '/organisation/:id' do
	o = Organisation.get params[:id]
	o.destroy
	redirect '/'
end

get '/:id/display' do
	puts "Project Display"
	@project = Project.get params[:id]
	@title = "Project for #{params[:id]}"
	erb :display
end

get '/organisation/:id/display' do
	@organisation = Organisation.get params[:id]
	@project = Project.all
	@title = "Organisation for #{params[:id]}"
	erb :displayOrg
end

get '/organisation/:id/edit' do
	@organisation = Organisation.get params[:id]
	@title = "Organisation for #{params[:id]}"
	erb :editOrg
end



put '/organisation/:id' do
	o = Organisation.get params[:id]
	o.name = params[:name]
	o.street_address = params[:street_address]
	o.state = params[:state]
	o.postal_code = params[:postal_code]
	o.country = params[:country]
	o.contact_number = params[:contact_number]
	o.credit_check = params[:credit_check]
	o.tax_deductability = params[:tax_deductability]
	o.description = params[:description]
	o.total_staff = params[:total_staff]
	o.total_countries = params[:total_countries]
	o.total_donations = params[:total_donations]
    o.save
	redirect '/organisation'
end