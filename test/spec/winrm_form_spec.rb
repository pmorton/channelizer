require './lib/test.rb'
describe "winrm object form" do
  it 'should expose a session' do
    c = Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :username => 'vagrant', :password => 'vagrant') 
    c.session.should be_a_kind_of(WinRM::WinRMWebService)
  end

  it 'should respond to instance methods of the base interface' do
    c = Channelizer::Factory.build_channel(:winrm, :host => 'localhost', :username => 'vagrant', :password => 'vagrant')
    c.should respond_to(:execute,:upload,:shell_execute,:sudo_command, :ready?)
  end

  it 'should respond to class methods of the base interface' do
    Channelizer::Channels::WinRM.should respond_to(:validate_options)
  end
end