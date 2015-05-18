Bundler.require :default

require 'singleton'
require 'active_support/core_ext/module/delegation.rb'
require_relative 'my_q'

CONFIG = YAML.load_file 'settings.yml'

class Garage
  include Singleton

  def self.method_missing(method_name, *args, &block)
    instance.send method_name, *args, &block
  end

  attr_accessor :my_q

  delegate *%i{status open! close!}, to: :my_q

  def initialize
    @my_q = MyQ::Client.new username: CONFIG['my_q']['user'], password: CONFIG['my_q']['pass'], door_id: CONFIG['my_q']['door_id']
  end
end

class OpenHABUpdater
  BASE_URL = CONFIG['openhab']['base_url'].freeze
  ITEM     = CONFIG['openhab']['item_name'].freeze
  HEADERS  = {"Content-Type" => "text/plain"}.freeze

  def self.update!(status)
    puts "#{BASE_URL}#{ITEM}/state/ = #{status}"
    HTTParty.put "#{BASE_URL}#{ITEM}/state/", headers: HEADERS, body: status
  end
end
