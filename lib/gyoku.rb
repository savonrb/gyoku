require "gyoku/version"
require "gyoku/hash"

module Gyoku
  class << self

    # Translates a given +hash+ with +options+ to XML.
    def xml(hash, options = {})
      Hash.to_xml deep_dup(hash), options
    end

    # Yields this object for configuration.
    def configure
      yield self
    end

    # Sets the formula for converting Symbol keys.
    def convert_symbols_to(formula = nil, &block)
      XMLKey.symbol_converter = formula ? formula : block
    end

    private

    def deep_dup(object)
      case object
      when Array
        temp = []
        object.each { |it| temp << deep_dup(it) }
        temp
      when Hash
        temp = {}
        object.each { |k,v| temp[k] = deep_dup(v) }
        temp
      else
        begin
          object.clone
        rescue TypeError
          object
        end
      end
    end

  end
end
