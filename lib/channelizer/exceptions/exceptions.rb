module Channelizer
  module Exceptions
    # Generic Channel Error
    class ChannelError < StandardError ; end

    # Invalid Exit Code
    class BadExitCode < StandardError ; end

    # Invalid Channel Type Code
    class InvalidChannelTypeError < StandardError ; end

  end
end