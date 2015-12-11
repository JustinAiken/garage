Bundler.require :default

require 'singleton'
require 'active_support/core_ext/module/delegation.rb'
require_relative 'my_q'

CONFIG   = YAML.load_file 'settings.yml' rescue {'openhab' => {}, 'my_q' => {}}
USERNAME = (ENV["MYQ_USER"]         || CONFIG['my_q']['user']).freeze
PASSWORD = (ENV["MYQ_PASS"]         || CONFIG['my_q']['pass']).freeze
DOOR_ID  = (ENV["MYQ_DOOR_ID"]      || CONFIG['my_q']['door_id']).freeze
BASE_URL = (ENV["OPENHAB_URL"]      || CONFIG['openhab']['base_url']).freeze
ITEM     = (ENV["OPENHAB_ITEMNAME"] || CONFIG['openhab']['item_name']).freeze
HEADERS  = {"Content-Type" => "text/plain"}.freeze

class Garage
  include Singleton

  def self.method_missing(method_name, *args, &block)
    instance.send method_name, *args, &block
  end

  attr_accessor :my_q

  delegate *%i{status open! close!}, to: :my_q

  def initialize
    @my_q = MyQ::Client.new username: USERNAME, password: PASSWORD, door_id: DOOR_ID
  end
end

class OpenHABUpdater

  def self.update!(status)
    puts "#{BASE_URL}#{ITEM}/state/ = #{status}"
    HTTParty.put "#{BASE_URL}#{ITEM}/state/", headers: HEADERS, body: status
  end
end
