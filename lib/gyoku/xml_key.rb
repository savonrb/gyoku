require "gyoku/core_ext/string"

module Gyoku
  module XMLKey

    # Converts a given +object+ to an XML key.
    def to_xml_key(key)
      case key
        when Symbol then chop_exclamation_mark(key.to_s).lower_camelcase
        else             chop_exclamation_mark(key.to_s)
      end
    end

  private

    # Chops existing exclamation marks from the end of a given +string+.
    def chop_exclamation_mark(string)
      string[-1, 1] == "!" ? string.chop : string
    end

  end
end
