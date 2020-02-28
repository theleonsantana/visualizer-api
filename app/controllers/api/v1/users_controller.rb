require 'rest-client'

class Api::V1::UsersController < ApplicationController

  def index 
    @users = User.all
    render json: @users 
  end

  def show
    @user = User.find_by(id: params[:id])
    render json: @user
  end

  # create user
  def create
  
    body = {
      grant_type: 'authorization_code',
      code: params[:code],
      redirect_uri: 'http://localhost:3000/api/v1/user',
      client_id: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_id],
      client_secret: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_secret]
    }

    if params[:error] == "access_denied"
      redirect_to "http://localhost:3006/login"
    else
      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
      auth_params = JSON.parse(auth_response.body)

      header = {
        Authorization: "Bearer #{auth_params["access_token"]}"
      }

      user_response = RestClient.get("https://api.spotify.com/v1/me", header)
      user_params = JSON.parse(user_response.body)

      @user = User.find_or_create_by(
        name: user_params["display_name"],
        user_spotify_url: user_params["external_urls"]["spotify"],
        user_spotify_id: user_params["id"])

      image = user_params["images"][0] ? user_params["images"][0]["url"] : nil
      country = user_params["country"] ? user_params["country"] : nil
    
      @user.update(user_image: image, country: country)

      # if @user.access_token_expired?
      #   @user.refresh_access_token
      # else
      #   @user.update(
      #     access_token: auth_params["access_token"],
      #     refresh_token: auth_params["refresh_token"]
      #   )
      # end
    
      cookies[:access_token_visualizer] = {
        value: auth_params["access_token"],
        expires: 1.hour.from_now, 
      }

      cookies[:user_id] = {
        value: user_params["id"],
        expires: 1.hour.from_now, 
      }
    
      redirect_to "http://localhost:3006/app"
    end
    
  end

  # assigns id to user
  def update
    @user = User.find_by(id: params[:id])
    puts "params[:id]",  params[:id]
  end

  def destroy 
    @user = User.find_by(id: params[:id])
    @user.destroy
  end

  private
  # Params to match my data structure 
  def user_params
    params.require(:user).permit(:id, :name, :user_image, :country, :user_spotify_url, :user_spotify_id, :access_token, :refresh_token)
  end
end
