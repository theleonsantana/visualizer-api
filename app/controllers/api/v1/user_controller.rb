require 'rest-client'

class Api::V1::UserController < ApplicationController

  def index 
    @users = User.all
    render json: @users 
  end

  def create 

    body = {
      grant_type: 'authorization_code',
      code: params[:code],
      redirect_uri: 'http://localhost:3000/api/v1/user',
      client_id: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_id],
      client_secret: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_secret]
    }

    auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
    auth_params = JSON.parse(auth_response.body)

    header = {
      Authorization: "Bearer #{auth_params["access_token"]}"
    }

    private

  # Params to match my data structure 
  def user_params
    params.require(:user).permit(:id, :name, :user_image, :country, :user_spotify_url, :spotify_id, :access_token, :refresh_token)
  end
end
