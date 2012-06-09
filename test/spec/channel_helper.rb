$: << File.dirname(__FILE__) + '/../../lib/'

module ChannelHelper

  def winrm_connection
    Channelizer::Factory.build_channel(:winrm, :username => 'vagrant', :password => 'vagrant', :host => 'localhost', :port => 5985)
  end

end

RSpec.configure do |config|
  config.include(ChannelHelper)
end