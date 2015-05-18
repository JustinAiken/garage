class MyQ
  APP_ID = "Vj8pQggXLhLy0WHahglCD4N1nAkkXQtGYpq2HrHD7H1nvmbT55KqtN6RSF4ILB%2Fi"
  LOCALE = "en"

  HOST_URI               = "myqexternal.myqdevice.com"
  LOGIN_ENDPOINT         = "Membership/ValidateUserWithCulture"
  DEVICE_LIST_ENDPOINT   = "api/UserDeviceDetails"
  DEVICE_SET_ENDPOINT    = "Device/setDeviceAttribute"
  DEVICE_STATUS_ENDPOINT = "/Device/getDeviceAttribute"

  DOOR_STATE_URI         = "https://#{MyQ::HOST_URI}/#{MyQ::DEVICE_SET_ENDPOINT}"

  STATES = {
    '1' => 'open',
    '2' => 'closed',
    '4' => 'opening',
    '5' => 'closing',
    '9' => 'open'
  }
end

class MyQ::Client

  NoTokenError = Class.new StandardError
  GARAGE_PATH  = 'garage'

  def initialize(username: nil, password: nil, token: nil, door_id: nil)
    @username = username
    @password = password
    @token    = read_token || fetch_token
    @door_id  = door_id
  end

  def status
    state = HTTParty.get(check_door_state_uri).parsed_response["AttributeValue"]
    MyQ::STATES[state]
  end

  def open!
    change_door_state! 1
  end

  def close!
    change_door_state! 0
  end

private

  def read_token
    return unless File.exist? GARAGE_PATH
    File.open GARAGE_PATH, 'r' do |file|
      @token = file.gets
    end
    @token
  rescue => e
    puts e.inspect
  end

  def fetch_token
    token = HTTParty.get(login_uri).parsed_response["SecurityToken"]
    raise NoTokenError unless token
    File.open(GARAGE_PATH, 'w') { |f| f.write token }
    token
  end

  def login_uri
    "https://#{MyQ::HOST_URI}/".tap do |uri|
      uri << "#{MyQ::LOGIN_ENDPOINT}"
      uri << "?appId=#{MyQ::APP_ID}"
      uri << "&securityToken=null"
      uri << "&username=#{@username}"
      uri << "&password=#{@password}"
      uri << "&culture=#{MyQ::LOCALE}"
    end
  end

  def check_door_state_uri
    "https://#{MyQ::HOST_URI}/".tap do |uri|
      uri << "#{MyQ::DEVICE_STATUS_ENDPOINT}"
      uri << "?appId=#{MyQ::APP_ID}"
      uri << "&securityToken=#{@token}"
      uri << "&devId=#{@door_id}"
      uri << "&name=doorstate"
    end
  end

  def change_door_state!(state_val)
    HTTParty.put(MyQ::DOOR_STATE_URI,
      body: {
        AttributeName:  "desireddoorstate",
        DeviceId:       @door_id,
        ApplicationId:  MyQ::APP_ID,
        AttributeValue: state_val,
        SecurityToken:  @token
      }
    )
  end
end
