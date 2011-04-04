require "gyoku/core_ext/string"

module Gyoku
  module XMLKey
    class << self

      # Converts a given +object+ with +options+ to an XML key.
      def create(key, options = {})
        xml_key = chop_special_characters key.to_s

        if unqualify?(xml_key)
          xml_key = xml_key.split(":").last
        elsif qualify?(options) && !xml_key.include?(":")
          xml_key = "#{options[:namespace]}:#{xml_key}"
        end

        case key
          when Symbol then xml_key.lower_camelcase
          else             xml_key
        end
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
