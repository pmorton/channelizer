module Channelizer
  module Channels
    class WinRM < Channelizer::Channels::Base

      # @return [WinRM::WinRMWebService] the winrm management session
      attr_reader :session

      required_option :host
      required_option :port
      required_option [[:username,:password], :realm]

      # Creates a WinRM Channel
      #
      # @option options [String] :username the username
      # @option options [String] :password the password
      # @option options [String] :host the remote host
      # @option options [String] :port (5985) the port to connect on
      # @option options [String] :realm the realm to use when using kerberos authentication
      def initialize(options)
        defaults = { :port => 5985, :basic_auth_only => true }
        options = defaults.merge(options)
        options[:pass] = options[:password] if options[:password]
        options[:user] = options[:username] if options[:username]

        # Options need to be in a final state before we call the parent initializer
        super(options)

        endpoint = "http://#{options[:host]}:#{options[:port]}/wsman"

        if options[:realm]
          @session = ::WinRM::WinRMWebService.new(endpoint, :kerberos, :realm => options[:realm])
        else
          @session = ::WinRM::WinRMWebService.new(endpoint, :plaintext, options)
        end

      end

      # Executes a command on the channel
      #
      # @param command the command to execute on the channel
      # @return [Fixnum] the exit code of the command
      # @raise [StandardException]
      def execute(command, options = { })
        defaults = { :shell => :cmd }
        options = defaults.merge(options)

        run_proc = Proc.new do |stdout, stderr|
          STDOUT.print stdout
          STDERR.print stderr
        end

        shell = options.delete(:shell)
        case shell
        when :cmd
          status = session.cmd(command,&run_proc) 
        when :powershell
          status = session.powershell(command, &run_proc)
        else
          raise StandardError, "Invalid shell #{options[:shell]}"
        end
        status[:exitcode]
      end

      # Echos the command (Windows does not support sudo)
      #
      # @param [String] command the command to wrap in a sudo context
      # @return [String] the command that has been wrapped in a sudo context
      def sudo_command(command)
        command
      end

      # Uploads a file over WinRM
      #
      # @param source the file to upload
      # @param destination where to place the file on the remote host
      # @return [Fixnum] 
      def upload(source, destination, options = {} )
        file = "winrm-upload-#{rand()}"
        puts "File: " + file
        file_name = (session.cmd("echo %TEMP%\\#{file}"))[:data][0][:stdout].chomp
        puts "File Name: " + file_name
        puts session.powershell <<-EOH
          if(Test-Path #{destination})
          {
            rm #{destination}
          }
        EOH

        Base64.encode64(IO.binread(source)).gsub("\n",'').chars.to_a.each_slice(8000-file_name.size) do |chunk|
          out = session.cmd( "echo #{chunk.join} >> \"#{file_name}\"" )
          puts out
        end

        puts session.powershell <<-EOH
          $dir = [System.IO.Path]::GetDirectoryName(\"#{destination}\")
          Write-host $dir
          New-Item $dir -type directory -ea SilentlyContinue
        EOH

        puts session.powershell <<-EOH
          $base64_string = Get-Content \"#{file_name}\"
          $bytes  = [System.Convert]::FromBase64String($base64_string) 
          $new_file = [System.IO.Path]::GetFullPath(\"#{destination}\")
          [System.IO.File]::WriteAllBytes($new_file,$bytes)
        EOH
      end

    end
  end
end

Channelizer::Factory.register(:winrm, Channelizer::Channels::WinRM)