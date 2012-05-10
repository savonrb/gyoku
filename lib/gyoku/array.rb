require "builder"

require "gyoku/hash"
require "gyoku/xml_value"

module Gyoku
  class Array

    # Translates a given +array+ to XML. Accepts the XML +key+ to add the elements to,
    # whether to +escape_xml+ and an optional Hash of +attributes+.
    def self.to_xml(array, key, escape_xml = true, attributes = {}, options = {})
      iterate_with_xml array, attributes do |xml, item, attrs, index|
        case item
          when ::Hash   then xml.tag!(key, attrs) { xml << Hash.to_xml(item, options) }
          when NilClass then xml.tag!(key, "xsi:nil" => "true")
          else               xml.tag!(key, attrs) { xml << XMLValue.create(item, escape_xml) }
        end
      end
    end

  private

    # Iterates over a given +array+ with a Hash of +attributes+ and yields a builder +xml+
    # instance, the current +item+, any XML +attributes+ and the current +index+.
    def self.iterate_with_xml(array, attributes)
      xml = Builder::XmlMarkup.new
      array.each_with_index do |item, index|
        yield xml, item, tag_attributes(attributes, index), index
      end
      xml.target!
    end

    # Takes a Hash of +attributes+ and the +index+ for which to return attributes
    # for duplicate tags.
    def self.tag_attributes(attributes, index)
      return {} if attributes.empty?

      attributes.inject({}) do |hash, (key, value)|
        value = value[index] if value.kind_of? ::Array
        value ? hash.merge(key => value) : hash
      end
    end

  end
end
