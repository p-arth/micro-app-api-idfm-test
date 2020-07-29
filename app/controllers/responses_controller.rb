require 'json'
require 'pry'
require 'rest-client'
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

    result = RestClient.post( urlOAuth, data )
    result = JSON.parse(result)

    token = result['access_token']
    binding.pry

    apiUrl = 'https://traffic.api.iledefrance-mobilites.fr/v1/tr-global/estimated-timetable'

    apiData = {
      LineRef: 'ALL'
    }

    apiHeaders = {
      'Accept-Encoding': '',
      'Authorization': 'Bearer ' + token
    }

    finalResult = RestClient.get( apiUrl, headers = apiHeaders )
    binding.pry
    jsonData = JSON.parse(finalResult)
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

    urlOAuth = 'https://as.api.iledefrance-mobilites.fr/api/oauth/token'
    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    data = {
      grant_type: 'client_credentials',
      scope: 'read-data',
      client_id: client_id,
      client_secret: client_secret
    }

    result = RestClient.post( urlOAuth, data )
    result = JSON.parse(result)

    token = result['access_token']
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
