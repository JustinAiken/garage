require 'pathname'
require 'bundler'
require 'sinatra'

APP_ROOT = Pathname.new File.expand_path('../',  __FILE__)
require "#{APP_ROOT}/garage.rb"

class GarageServer < Sinatra::Base
  get '/status' do
    Garage.status
  end

  get '/open' do
    Garage.open!
  end

  get '/close' do
    Garage.close!
  end

  get '/update' do
    status = Garage.status
    if %w{open closed opening closing}.include? status
      OpenHABUpdater.update! status
    else
      puts "Unknown status: #{status}"
    end
  end
end
