module Channelizer
  module Channels
    class Base
      include Channelizer::Exceptions
      include Channelizer::Util::Retryable

      def initialize(options)
        self.class.validate_options(options)  
      end
      # Executes a command on the channel
      #
      # @param [String] command the command to execute on the channel
      # @param [Hash] options the options string to be used in executing the command
      # @option options [Array] :exit_codes ([0]) the valid exit codes for the command
      # @option options [TrueClass,FalseClass] :check_exit_code (true) make that the command returned a valid exit code
      # @return [Fixnum] the exit code of the command
      # @raise [BadExitCode] The command exited with a bad exitcode
      def shell_execute(command, options = {})
        defaults = {:exit_codes => [0], :check_exit_code => true, :sudo => false}
        options = defaults.merge(options)

        new_command = options[:sudo] ? sudo_command(command) : command

        exit_code = execute(new_command, options)

        if not options[:exit_codes].include? exit_code and options[:check_exit_code]
          raise BadExitCode, "Exit Code: #{exit_code}"
        end

        exit_code.to_i
      end

      # Returns a command wrapped in a sudo context
      #
      # @param [String] command the command to wrap in a sudo context
      # @return [String] the command that has been wrapped in a sudo context
      # @raise [NotImplementedError] this method has not been implemented
      def sudo_command(command)
        raise NotImplementedError, "sudo command not implemented"  
      end

      # Executes a command on the channel
      #
      # @param command the command to execute on the channel
      # @return [Fixnum] 
      # @raise [NotImplementedError] this method has not been implemented
      def execute(command, options = {})
        raise NotImplementedError, "Execute not implemented"
      end

      # Uploads a file over the channel
      #
      # @param source the file to upload
      # @param destination where to place the file on the remote host
      # @return [Fixnum] 
      # @raise [NotImplementedError] this method has not been implemented
      def upload(source, destination, options = {} )
        raise NotImplementedError, "Upload not implemented"
      end

      # Checks if the channel is ready for action
      #
      # @return [TrueClass,FalseClass]
      def ready?
        begin
          Timeout.timeout(60) do
            execute "hostname"
          end
          return true
        rescue Timeout::Error => e
          return false
        rescue Errno::ECONNREFUSED => e
          return false
        rescue HTTPClient::KeepAliveDisconnected => e
          return false
        end
      end

      class <<self
      # Validates the option set for the channel
      #
      # @param [Hash] options the options hash to validate
      # @return [True]
      def validate_options(options)
        @required_options.each do |o|
          if o.is_a? Array
            # At least one of the items in an array must be set, if the value is
            # an array it is treated as a group of arguments that are required.
            condition_met = false
            o.each do |o_set|
              if o_set.is_a? Array
                included_options = []
                o_set.each do |o_req_set|
                  included_options << o_req_set if options[o_req_set]
                end
                condition_met = true if included_options.length.eql?(o_set.length)
              else
                condition_met = true if options[o_set]
              end
            end
            raise ArgumentError, "You must specify one of #{o.inspect}" unless condition_met
          else
            raise ArgumentError, "#{o} is a required option, but was not provided"  unless options[o]

            if options[o].respond_to? :empty?
              raise ArgumentError, "#{o} cannot be empty" if options[o].empty?
            end  
          end
        end
        true
      end

      # Register a required option
      #
      # @param [Symbol] value the option name that is required
      def required_option(value)
        @required_options ||= []
        if value.respond_to? :to_sym
          @required_options << value.to_sym
        elsif value.is_a? Array
          @required_options << value
        else
          raise ArgumentError, "#{value.inspect} cannot be added to the validation list"  
        end
      end
      end

    end
  end
end