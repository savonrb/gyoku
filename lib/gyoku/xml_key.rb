require "gyoku/core_ext/string"

module Gyoku
  module XMLKey

    # Converts a given +object+ with +options+ to an XML key.
    def to_xml_key(key, options = {})
      qualify = options[:element_form_default] == :qualified ? options[:namespace] : false
      xml_key = chop_special_characters key.to_s
      xml_key = "#{qualify}:#{xml_key}" if qualify && !xml_key.include?(":")

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

  end
end
