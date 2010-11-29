require "builder"

require "gyoku/array"
require "gyoku/xml_key"
require "gyoku/xml_value"

module Gyoku
  class Hash
    extend XMLKey
    extend XMLValue

    # Translates a given +hash+ to XML.
    def self.to_xml(hash)
      iterate_with_xml hash do |xml, key, attributes|
        attrs = attributes[key] || {}
        value = hash[key]
        escape_xml = key.to_s[-1, 1] != "!"
        key = to_xml_key(key)
        
        case value
          when ::Array  then xml << Array.to_xml(value, key, escape_xml, attrs)
          when ::Hash   then xml.tag!(key, attrs) { xml << Hash.to_xml(value) }
          when NilClass then xml.tag!(key, "xsi:nil" => "true")
          else               xml.tag!(key, attrs) { xml << to_xml_value(value, escape_xml) }
        end
      end
    end

  private

    # Iterates over a given +hash+ and yields a builder +xml+ instance, the current
    # Hash +key+ and any XML +attributes+.
    def self.iterate_with_xml(hash)
      xml = Builder::XmlMarkup.new
      attributes = hash.delete(:attributes!) || {}
      
      order(hash).each { |key| yield xml, key, attributes }
      
      xml.target!
    end

    # Deletes and returns an Array of keys stored under the :order! key of a given +hash+.
    # Defaults to return the actual keys of the Hash if no :order! key could be found.
    # Raises an ArgumentError in case the :order! Array does not match the Hash keys.
    def self.order(hash)
      order = hash.delete :order!
      order = hash.keys unless order.kind_of? ::Array
      
      missing, spurious = hash.keys - order, order - hash.keys
      raise ArgumentError, "Missing elements in :order! #{missing.inspect}" unless missing.empty?
      raise ArgumentError, "Spurious elements in :order! #{spurious.inspect}" unless spurious.empty?
      
      order
    end

  end
end
