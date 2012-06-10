$: << File.dirname(__FILE__) + '/../../lib/'

module ChannelHelper

  def new_channel(type)
    case type
    when :winrm
      Channelizer::Factory.build_channel(type, :username => 'vagrant', :password => 'vagrant', :host => 'localhost', :port => 5985)
    when :ssh
      Channelizer::Factory.build_channel(type, :username => 'vagrant', :keys => ['/Users/pmorton/.ssh/deploy'],:password => 'vagrant', :host => 'localhost', :port => 2200)  
    end
  end

end

RSpec.configure do |config|
  config.include(ChannelHelper)
end