require "gyoku/version"
require "gyoku/hash"

module Gyoku
  class << self

    # Translates a given +hash+ with +options+ to XML.
    def xml(hash, options = {})
      Hash.to_xml hash.dup, options
    end

    # Yields this object for configuration.
    def configure
      yield self
    end

    # Sets the formula for converting Symbol keys.
    def convert_symbols_to(formula = nil, &block)
      XMLKey.symbol_converter = formula ? formula : block
    end

  end
end
