class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.find(:all, :order => "username")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
  
  def startcalls
    phonenumbers = params[:phone_number]
    phonenumbers = phonenumbers.gsub("-","").gsub("(","").gsub(")","").gsub(" ","")
    
    response = RestClient.get "http://api.tropo.com/1.0/sessions?action=create&token=0e0a2a5742a75c4ea...39b34fee05bc42b68f745818848&phones=#{phonenumbers}"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        render json: @users 
        if response.code == 200
          puts "Msg sent HTTP/#{response.code}"
          true
        else
          puts "ERROR | HTTP/#{response.code}"
          false
        end
        }
    end


    
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
