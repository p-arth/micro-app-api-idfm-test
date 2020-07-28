require 'json'
require 'open-uri'
require 'pry'
require 'rest-client'
require 'net/http'
require 'uri'
require 'active_support/all'

class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :destroy]

  # GET /responses
  def index
    urlOAuth = 'https://as.api.iledefrance-mobilites.fr/api/oauth/token'
    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    data = {
      grant_type: 'client_credentials',
      scope: 'read-data',
      client_id: client_id,
      client_secret: client_secret
    }

    # uri = URI.parse('https://as.api.iledefrancemobilites.fr/api/oauth/token')
    binding.pry



    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # request = Net::HTTP::Post.new(uri.path)
    # request.body = data.to_json

    # result = http.request(request)

    result = RestClient.post( urlOAuth, data )
    result = JSON.parse(result)

    binding.pry



    @response = Response.new(response_params)

    if @response.save
      render json: @response, status: :created, location: @response
    else
      render json: @response.errors, status: :unprocessable_entity
    end
  end

  # GET /responses/1
  def show
    render json: @response
  end

  # POST /responses
  def create
    binding.pry
    urlOAuth = 'https://as.api.iledefrancemobilites.fr/api/oauth/token'
    client_id = '4405c642-cba8-4e4f-8f29-12aabf069ae6'
    client_secret = '519f9d77-8a40-4a8e-9a2a-5e26a83ec029'

    data = {
      grant_type: 'client_credentials',
      scope: 'read-data',
      client_id: client_id,
      client_secret: client_secret
    }

    result = RestClient.post(urlOAuth, data).to_json
    binding.pry



    @response = Response.new(response_params)

    if @response.save
      render json: @response, status: :created, location: @response
    else
      render json: @response.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /responses/1
  def update
    if @response.update(response_params)
      render json: @response
    else
      render json: @response.errors, status: :unprocessable_entity
    end
  end

  # DELETE /responses/1
  def destroy
    @response.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def response_params
      params.fetch(:response, {})
    end
end
