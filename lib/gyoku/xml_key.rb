module Gyoku
  module XMLKey
    class << self

      CAMELCASE = lambda { |key| key.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase } }
      LOWER_CAMELCASE = lambda { |key| key[0].chr.downcase + CAMELCASE.call(key)[1..-1] }

      FORMULAS = {
        :lower_camelcase => lambda { |key| LOWER_CAMELCASE.call(key) },
        :camelcase       => lambda { |key| CAMELCASE.call(key) },
        :none            => lambda { |key| key }
      }

      # Converts a given +object+ with +options+ to an XML key.
      def create(key, options = {})
        xml_key = chop_special_characters key.to_s

        if unqualified = unqualify?(xml_key)
          xml_key = xml_key.split(":").last
        end

        xml_key = symbol_converter.call(xml_key) if Symbol === key

        if !unqualified && qualify?(options) && !xml_key.include?(":")
          xml_key = "#{options[:namespace]}:#{xml_key}"
        end

        xml_key
      end

      # Returns the formula for converting Symbol keys.
      def symbol_converter
        @symbol_converter ||= FORMULAS[:lower_camelcase]
      end

      # Sets the +formula+ for converting Symbol keys.
      # Accepts one of +FORMULAS+ of an object responding to <tt>:call</tt>.
      def symbol_converter=(formula)
        formula = FORMULAS[formula] unless formula.respond_to? :call
        raise ArgumentError, "Invalid symbol_converter formula" unless formula

        @symbol_converter = formula
      end

    private

      # Chops special characters from the end of a given +string+.
      def chop_special_characters(string)
        ["!", "/"].include?(string[-1, 1]) ? string.chop : string
      end

      # Returns whether to remove the namespace from a given +key+.
      def unqualify?(key)
        key[0, 1] == ":"
      end

      # Returns whether to namespace all keys (elementFormDefault).
      def qualify?(options)
        options[:element_form_default] == :qualified && options[:namespace]
      end

    end
  end
end
