require 'winrm'
require './lib/util/retryable.rb'
require './lib/exceptions/exceptions.rb'
require './lib/factory.rb'
require './lib/channels/base.rb'
require './lib/channels/winrm.rb'


#c = Channelizer::Channels::WinRM.new(:username => 'vagrant', :password => 'vagrant', :host => 'localhost', :port => 5985)
#c.shell_execute 'get-item C:\\', :exit_codes => [1,2], :shell => :powershell, :sudo => true
#c.upload('test.rb', 'C:\test.rb')
#c.shell_execute 'cat c:\test.rb', :shell => :powershell
#c = Channelizer::Factory.build_channel(:winrm, :username => 'vagrant', :password => 'vagrant', :host => 'localhost', :port => 5985)

#puts c.shell_execute 'hostname'