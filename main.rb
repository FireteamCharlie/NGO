require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'bcrypt'
#require 'carrierwave'
#require 'carrierwave/datamapper'

#class MyUploader < CarrierWave::Uploader::Base    #via a Carrierwave tutorial
#  storage :file
#  def store_dir
#    'Public/Images/'
#  end
#end

#use Rack::Session::EncryptedCookie, :secret => "\xF7\xAF\x18\xAA\xFFK\x94E\xF0\x82^\x11\x1A?}\x9C"
enable :sessions
use Rack::Session::Cookie, :secret => "\xF7\xAF\x18\xAA\xFFK\x94E\xF0\x82^\x11\x1A?}\x9C"


userTable = {}

helpers do

  def admin?
  	if session[:username] == 'Luke'
  	end
  end
  
  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end
  
  def username
    return session[:username]
  end

  def firstname
  	return session[:firstname]
  end

  def lastname
  	return session[:lastname]
  end

  
end


#DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/project.db")

DataMapper.setup(:default, 'postgres://localhost/project')


class Project
	include DataMapper::Resource
	property :project_id, Serial
	property :project_name, Text
	property :sector, Text
	property :country, Text
	property :rating, Text
	property :description, Text
	property :summary, Text
	property :funding_goal, Float
	property :current_funding, Float, :default  => 0
	property :funding_date, DateTime
	property :created_at, DateTime
	property :updated_at, DateTime
	property :status, Text
	#mount_uploader :image, MyUploader    
	belongs_to :organisation
	has n, :donations
	has n, :updates
end

class Organisation
	include DataMapper::Resource
	property :organisation_id, Serial
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
	property :total_donations, Float
	has n, :projects
end

class Donation
	include DataMapper::Resource
	property :donation_id, Serial
	property :donor, Text
	property :amount, Float
	property :time, Time
	property :cardnumber, Text
	property :expiry, Text
	property :ccv, Text
	belongs_to :project
end

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :firstname, Text
  property :lastname, Text
  property :username, String, :length => 3..50
  property :password, BCryptHash
  property :emailaddress, Text
end

class Update
  include DataMapper::Resource

  property :update_id, Serial
  property :postname, Text
  property :postcontent, Text
  property :posttime, Time
  belongs_to :project
end

DataMapper.finalize.auto_upgrade!


get "/authtest" do
	puts login?
	puts username
	puts session
	require 'pry'
	binding.pry
end

get "/signup" do
	@title = "Sign Up"	
  erb :signup
end
 
post "/signup" do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  
  
  user = User.new
  user.firstname = params[:firstname]
  user.lastname = params[:lastname]
  user.username = params[:username]
  user.password = params[:password]
  user.save
  
  session[:username] = params[:username]
  redirect "/"
end
 
post "/login" do
  puts params[:username]
  user = User.first(:username => params[:username])
  if not user.nil?
  	puts user
    if user.password == params[:password]
      puts 'valid password!!'
      # Need to find out how I can output values from the session into Terminal
      session[:username] = params[:username]
      session[:firstname] = params[:firstname]
      session[:lastname] = params[:lastname]
      redirect "/"
    end
  else 
  	redirect "/error"
  end
  @title = "Unauthorised User"
  erb :error
end
 
get "/logout" do
  session[:username] = nil
  redirect "/"
end

get "/auth" do
	@title = "Login"
	erb :auth
end


get "/user/:username" do
	@title = "User Profile"
	@user = User.first(:username => params[:username])
	@donations = Donation.all(:donor => params[:username])
	puts @donations
	puts @user.firstname
	puts @user.lastname
	erb :user
end

get '/uploads/:image' do
end

get '/organisation/:organisation_id/projectAdd' do
	@title = "New Project"
	@organisation_id = params[:organisation_id]
	erb :newProject
end

post '/organisation/:organisation_id/projectAdd' do
  p params
  puts request.body.read   
  @org = Organisation.get(params[:organisation_id])
  r = Project.new 
  r.project_name = params[:project_name]
  r.sector = params[:sector]
  r.country = params[:country]
  r.rating = params[:rating]
  r.description = params[:description]
  r.summary = params[:summary]
  r.funding_goal = params[:funding_goal]
  r.funding_date = params[:funding_date]
  r.status = params[:status]
  r.image = params[:image]
  r.created_at = Time.now
  r.updated_at = Time.now
  r.organisation = @org
  puts r
  r.save
  redirect "/organisation/#{params[:organisation_id]}/display"
end

get '/about' do
	@title = 'About'
	erb :about
end

get '/admin' do
	@title = 'Admin'
	erb :admin
end

get '/all' do
	@project = Project.all
	@title = 'All Projects'
	erb :home
end

get '/' do
	projects = Project.all(:limit => 4,  :order => :project_id.desc)
	@title = 'Home'
	erb :index , :layout => :layout do
          a = erb :panel, :locals => { :projects => Project.all(:limit => 4, :status =>'Featured',  :order => :project_id.asc), :header => 'Featured' }
          b = erb :panel, :locals => { :projects => Project.all(:limit => 4, :status =>'Staff Pick', :order => :project_id.asc), :header => 'Staff Picks' }
          a + b
        end
end 

get '/organisation' do
	@organisation = Organisation.all
	@title = "All Organisations"
	erb :organisations
end

post '/project/' do
	r = Project.new
	r.project_name = params[:project_name]
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

get '/project/:project_id/updates' do
	@title = "Project Updates"
	@updates = Update.all
	puts @updates.postname
	puts "This worked"
	erb :updates
end

get '/project/:project_id/updates/add' do
	@title = "Create update #{params[:update_id]}"  
	@project = Project.get params[:project_id]
  	erb :addUpdate 
end

post '/project/:project_id/updates/add' do 
  @proj = Project.get params[:project_id]
  puts @proj
  u = Update.new 
  u.postname = params[:postname]
  u.postcontent = params[:postcontent]
  u.posttime = Time.now
  u.project = @proj
  puts u
  puts "About to save"
  p params
  puts request.body.read 
  #Change this to a thank you page at some stage
  u.save
  puts "Saved"
  redirect "/project/#{params[:project_id]}/display"
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



get '/project/add' do
  @title = "Create project #{params[:project_id]}"  
  erb :add  
end

get '/organisation/add' do
  @title = "Create organisation #{params[:organisation_id]}"  
  erb :addOrg  
end

post '/organisation' do
	o = Organisation.new
	o.name = params[:name]
    o.save
	redirect '/organisation'
end

get '/organisation/:organisation_id' do  
  @organisation = Organisation.get params[:organisation_id] 
  @project = Project.all(:sector => 'Agriculture')
  @title = "Edit organisation #{params[:name]}"  
  erb :displayOrg  
end  



get '/organisation/:organisation_id/add' do
	@title = "Create a new project for #{params[:name]}"
	@organisation_id = params[:organisation_id]
	@organisation = Organisation.get params[:organisation_id]
	erb :newProject
end

post '/organisation/:organisation_id/add' do
	r = Project.new
	r.project_name = params[:project_name]
	r.organisation = Organisation.get params[:organisation_id]
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


get '/organisation/:organisation_id/edit' do  
  @organisation = Organisation.get params[:organisation_id]  
  @title = "Edit organisation #{params[:name]}"  
  erb :editOrg  
end  

get '/project/:project_id/edit' do  
  @project = Project.get params[:project_id]  
  @title = "Edit project #{params[:project_id]}"  
  erb :edit  
end  



def save s
  unless s.save
    s.errors.each { |e| puts e }
    raise 'Error saving item'
  end
end

put '/project/:project_id' do
	r = Project.get params[:project_id]
	r.project_name = params[:project_name]
	r.sector = params[:sector]
	r.country = params[:country]
	r.rating = params[:rating]
	r.summary = params[:summary]
	r.description = params[:description]
	r.funding_goal = params[:funding_goal]
	r.current_funding = params[:current_funding]
	r.funding_date = params[:funding_date]
	r.current_funding = params[:current_funding]
	r.status = params[:status]
	r.updated_at = Time.now
	r.save
	redirect '/'
end



get '/project/:project_id/delete' do
	@project = Project.get params[:project_id]
	@title = "Confirm deletion of project #{params[:project_id]}"
	erb :delete
end

delete '/project/:project_id' do
	n = Project.get params[:project_id]
	n.destroy
	redirect '/organisation/#{params[:organisation_id]}'
end

get '/organisation/:organisation_id/delete' do
	@organisation = Organisation.get params[:organisation_id]
	@title = "Confirm deletion of organisation #{params[:organisation_id]}"
	erb :deleteOrg
end

delete '/organisation/:organisation_id' do
	o = Organisation.get params[:organisation_id]
	o.destroy
	redirect '/'
end

get '/project/:project_id/display' do
	@project = Project.get params[:project_id]
	@relatedproject = Project.all(:limit => 4)
	@title = "Project for #{params[:project_id]}"
	erb :display
end

get '/organisation/:organisation_id/display' do
	@organisation = Organisation.get params[:organisation_id]
	@org = Organisation.first(:organisation_id => params[:organisation_id])
    @project = Project.all(:organisation => @org)
    #@donation_count = @project.current_funding
    @project_count = @project.count
    puts @project_count
	@title = "Organisation for #{params[:organisation_id]}"
	erb :displayOrg
end

get '/organisation/:organisation_id/edit' do
	@organisation = Organisation.get params[:organisation_id]
	@title = "Organisation for #{params[:organisation_id]}"
	erb :editOrg
end



put '/organisation/:organisation_id' do
	o = Organisation.get params[:organisation_id]
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

get '/project/:project_id/donate' do
	@title = "Make a donation to #{params[:project_name]}"
	@project = Project.get params[:project_id]
	erb :donate
end

get '/project/:project_id/:donation_id' do
	@project = Project.get params[:project_id]
	@title = "Donations"
	@donation = Donation.get params[:donation_id]
	erb :donation
end

get '/donation/:donation_id/display' do
	@donation = Donation.get params[:donation_id]
	@title = "Donation details for #{params[:donation_id]}"
	erb :displayDonation
end

post '/project/:project_id/donate' do  
  @proj = Project.get params[:project_id]
  p @proj
  d = Donation.new 
  d.donor = username
  d.amount = params[:amount]
  d.time = Time.now
  d.project = @proj
  d.project.current_funding = d.project.current_funding + d.amount
  puts d.amount
  puts "About to save"
  d.save
  puts "Saved"
  p params
  puts request.body.read 
  #Change this to a thank you page at some stage
  redirect "/project/#{params[:project_id]}/display"
end

get '/admin' do
	erb :admin
end




