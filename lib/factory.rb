module Channelizer
  class Factory
    include Channelizer::Exceptions

    class << self

      def register(name,klass)
        @registered_channels ||= {}
        @registered_channels[name.to_sym] = klass
      end

      def build_channel(type,options)
        raise InvalidChannelTypeError, ":#{type} is not a registered channel" unless @registered_channels[type.to_sym]
        @registered_channels[type.to_sym].new(options)
      end
    end

  end
end