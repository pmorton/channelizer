$: << File.dirname(__FILE__)
require 'channel_helper'
require './lib/test.rb'

describe "winrm command execution" do 
  before(:all) do
    @winrm = winrm_connection
  end

  it 'should echo back a sudo command' do
    @winrm.sudo_command('test_command').should == "test_command"
  end

  it 'should execute a command sucessfully' do
    @winrm.execute('hostname').should == 0
  end

  it 'should execute in powershell when requested' do
    @winrm.execute('dir ENV:\\', :shell => :powershell).should == 0
    @winrm.execute('dir ENV:\\').should == 1
  end
end

describe "winrm shell execution" do
  before(:all) do
    @winrm = winrm_connection
  end

  it 'should except when non-zero exit code is specified' do
    expect {
      @winrm.shell_execute('exit 1')
    }.to raise_error(Channelizer::Exceptions::BadExitCode, /1/)
  end

  it 'should NOT except when non-zero exit code is specified and it has been told not to' do
    @winrm.shell_execute('exit 1',:check_exit_code => false)
  end

  it 'should except based on custom error codes' do
    expect {
      @winrm.shell_execute('exit 0', :exit_codes => [1,2])
    }.to raise_error(Channelizer::Exceptions::BadExitCode, /0/)
  end

  it 'should return the exit code of the command' do
    @winrm.shell_execute('exit 1',:check_exit_code => false).should == 1
  end
end

describe "winrm interogatory methods" do
  before(:all) do
    @winrm = winrm_connection
  end

  it 'should be ready' do
    @winrm.ready?.should == true
  end  
end

