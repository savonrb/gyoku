require "builder"

require "gyoku/array"
require "gyoku/xml_key"
require "gyoku/xml_value"

module Gyoku
  class Hash

    # Translates a given +hash+ with +options+ to XML.
    def self.to_xml(hash, options = {})
      iterate_with_xml hash do |xml, key, value, attributes|
        self_closing = key.to_s[-1, 1] == "/"
        escape_xml = key.to_s[-1, 1] != "!"
        xml_key = XMLKey.create key, options

        case
          when ::Array === value  then xml << Array.to_xml(value, xml_key, escape_xml, attributes, options)
          when ::Hash === value   then xml.tag!(xml_key, attributes) { xml << Hash.to_xml(value, options) }
          when self_closing       then xml.tag!(xml_key, attributes)
          when NilClass === value then xml.tag!(xml_key, "xsi:nil" => "true")
          else                         xml.tag!(xml_key, attributes) { xml << XMLValue.create(value, escape_xml) }
        end
      end
    end

  private

    # Iterates over a given +hash+ and yields a builder +xml+ instance, the current
    # Hash +key+ and any XML +attributes+.
    def self.iterate_with_xml(hash)
      xml = Builder::XmlMarkup.new
      attributes = hash[:attributes!] || {}
      hash_without_attributes = hash.reject { |key, value| key == :attributes! }

      order(hash_without_attributes).each do |key|
        yield xml, key, hash_without_attributes[key], (attributes[key] || {})
      end

      xml.target!
    end

    # Deletes and returns an Array of keys stored under the :order! key of a given +hash+.
    # Defaults to return the actual keys of the Hash if no :order! key could be found.
    # Raises an ArgumentError in case the :order! Array does not match the Hash keys.
    def self.order(hash)
      order = hash[:order!]
      hash_without_order = hash.reject { |key, value| key == :order! }
      order = hash_without_order.keys unless order.kind_of? ::Array

      missing, spurious = hash_without_order.keys - order, order - hash_without_order.keys
      raise ArgumentError, "Missing elements in :order! #{missing.inspect}" unless missing.empty?
      raise ArgumentError, "Spurious elements in :order! #{spurious.inspect}" unless spurious.empty?

      order
    end

  end
end
