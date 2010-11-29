module Gyoku
  module CoreExt
    module String

      # Returns the String in lowerCamelCase.
      def lower_camelcase
        str = dup
        str.gsub!(/\/(.?)/) { "::#{$1.upcase}" }
        str.gsub!(/(?:_+|-+)([a-z])/) { $1.upcase }
        str.gsub!(/(\A|\s)([A-Z])/) { $1 + $2.downcase }
        str
      end

    end
  end
end

String.send :include, Gyoku::CoreExt::String
