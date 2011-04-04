module Gyoku
  module CoreExt
    module String

      # Returns the String in lowerCamelCase.
      def lower_camelcase
        self[0].chr.downcase + self.camelcase[1..-1]
      end

      # Returns the String in CamelCase.
      def camelcase
        self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end

    end
  end
end

String.send :include, Gyoku::CoreExt::String
