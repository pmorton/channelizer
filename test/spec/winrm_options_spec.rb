require './lib/test.rb'
describe "winrm option parsing" do 
  it 'should require a host' do
    expect {
      Channelizer::Factory.build_channel(:winrm, :username => 'vagrant', :password => 'vagrant', :port => 5985)
    }.to raise_error(ArgumentError, /host is a required option/)
  end

  it 'should use the default port' do
      Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :username => 'vagrant', :password => 'vagrant')
  end

  # Requires a wokring kerberos setup
  #it 'should not require username and password if kerberos is specified' do
  #  Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :realm => 'test')
  #end

  it 'should require a username and password' do
    expect {
      Channelizer::Factory.build_channel(:winrm, :host => 'localhost')
    }.to raise_error(ArgumentError, /You must specify one of \[\[\:username, \:password\]/)  
  end

  it 'should require a username even if a password is given' do
    expect {
      Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :password => 'vagrant')
    }.to raise_error(ArgumentError, /You must specify one of \[\[\:username, \:password\]/)  
  end

  it 'should require a password even if a username is given' do
    expect {
      Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :username => 'vagrant')
    }.to raise_error(ArgumentError, /You must specify one of \[\[\:username, \:password\]/)  
  end

end

