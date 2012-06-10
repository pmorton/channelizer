$: << File.dirname(__FILE__)
require 'channel_helper'
require './lib/test.rb'

Channelizer::Factory.channels.each do |channel,klass| 
  puts "CLASS #{channel}"
  describe "#{channel} command execution" do 
    before(:all) do
      @channel = new_channel(channel.to_sym)
      puts @channel
    end

    it 'should echo back a sudo command' do
      @channel.sudo_command('test_command').should == "sudo test_command" unless channel.to_sym.eql? :winrm
    end

    it 'should execute a command sucessfully' do
      @channel.execute('hostname').should == 0
    end
  end

  describe "#{channel} shell execution" do
    before(:all) do
      @channel = new_channel(:winrm)
    end

    it 'should except when non-zero exit code is specified' do
      expect {
        @channel.shell_execute('exit 1')
      }.to raise_error(Channelizer::Exceptions::BadExitCode, /1/)
    end

    it 'should NOT except when non-zero exit code is specified and it has been told not to' do
      @channel.shell_execute('exit 1',:check_exit_code => false)
    end

    it 'should except based on custom error codes' do
      expect {
        @channel.shell_execute('exit 0', :exit_codes => [1,2])
      }.to raise_error(Channelizer::Exceptions::BadExitCode, /0/)
    end

    it 'should return the exit code of the command' do
      @channel.shell_execute('exit 1',:check_exit_code => false).should == 1
    end

    it 'should output stuff to the console' do
      STDOUT.should_receive(:print).with("test message\r\n")
      @channel.shell_execute('echo test message')
    end

    it 'should NOT output stuff to the console' do
      STDOUT.should_not_receive(:print).with("test message\r\n")
      @channel.shell_execute('echo test message', :out_console => false)
    end
  end

  describe "#{channel} upload" do
    before(:all) do
      @channel = new_channel(channel.to_sym)
    end

    
  end

  describe "#{channel} interogatory methods" do
    before(:all) do
      @channel = new_channel(channel.to_sym)
    end

    it 'should be ready' do
      @channel.ready?.should == true
    end  
  end
end

describe 'winrm specifc functionality' do
    before(:all) do
      @channel = new_channel(:winrm)
    end

    it 'should echo back a sudo command' do
      @channel.sudo_command('test_command').should == "test_command"
    end

    it 'should execute in powershell when requested' do
      @channel.execute('dir ENV:\\', :shell => :powershell).should == 0
      @channel.execute('dir ENV:\\').should == 1
    end

    it 'should upload a file' do
      @channel.upload('./test/spec/test_data/test_file.txt', 'C:\test_file.txt')
      STDOUT.should_receive(:print).with("This is a test upload")
      (@channel.execute "type test_file.txt") == 0     

    end

end

describe 'ssh specifc functionality' do
    before(:all) do
      @channel = new_channel(:ssh)
    end

    it 'should upload a file' do
      @channel.upload('./test/spec/test_data/test_file.txt', '/tmp/test_file.txt')
      STDOUT.should_receive(:print).with("This is a test upload")
      (@channel.execute "cat /tmp/test_file.txt") == 0     

    end

end

