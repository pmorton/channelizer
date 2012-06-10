require 'net/ssh'
require 'net/scp'
module Channelizer
  module Channels
    class Ssh < Channelizer::Channels::Base

      required_option :host
      required_option :port
      required_option [[:username,:password], :keys]

      # Creates a SSH Session 
      #
      # @option options [String] :username the username
      # @option options [String] :password the password
      # @option options [String] :host the remote host
      # @option options [String] :port (5985) the port to connect on
      # @option options [String] :keys the keys to try logging in with
      def initialize(options)
        defaults = { :port => 22, :paranoid => false }
        options = defaults.merge(options)

        # Options need to be in a final state before we call the parent initializer
        super(options)

        @connection_options = options

      end

      def session
        options = @connection_options.clone
        host = options.delete(:host)
        username = options.delete(:username)
        Net::SSH.start(host,username,options)
      end

      # Executes a command on the channel
      #
      # @param command the command to execute on the channel
      # @return [Fixnum] the exit code of the command
      # @raise [StandardException]
      def execute(command, options = { })
        defaults = { :out_console => true }
        options = defaults.merge(options)
        # open a new channel and configure a minimal set of callbacks, then run
        # the event loop until the channel finishes (closes)
        last_exit = -1
        channel = session.open_channel do |ch|

          #request pty for sudo stuff and so
          ch.request_pty do |ch, success|
            raise "Error requesting pty" unless success
          end
            
          ch.exec "#{command}" do |ch, success|
            raise "could not execute command" unless success


            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
              STDOUT.print data if options[:out_console]

            end

            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
              STDOUT.print data if options[:out_console]
            end

            channel.on_request("exit-signal") do |ch, data|
              last_exit = data.read_long
            end

            channel.on_request("exit-status") do |ch,data|
              last_exit = data.read_long
            end

          end
        end
        channel.wait
        last_exit
      end

      # Echos the command (Windows does not support sudo)
      #
      # @param [String] command the command to wrap in a sudo context
      # @return [String] the command that has been wrapped in a sudo context
      def sudo_command(command)
        "sudo #{command}"
      end

      # Uploads a file over WinRM
      #
      # @param source the file to upload
      # @param destination where to place the file on the remote host
      # @return [Fixnum] 
      def upload(source, destination, options = {} )
        options = @connection_options.clone
        host = options.delete(:host)
        username = options.delete(:username)
        channel = session.scp.upload(source,destination)
        channel.wait
      end
    end
  end
end

Channelizer::Factory.register(:ssh, Channelizer::Channels::Ssh)