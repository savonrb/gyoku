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
    #
    # Keys beginning with "@" are treated as explicit attributes for their container.
    # You can use both :attributes! and "@" keys to specify attributes.
    # In the event of a conflict, the "@" key takes precedence.
    def self.iterate_with_xml(hash)
      xml = Builder::XmlMarkup.new
      attributes = hash.delete(:attributes!) || {}

      order(hash).each do |key| 
        node_attr = attributes[key] || {}
        node_value = hash[key]

        if node_value.respond_to?(:keys)
          explicit_keys = node_value.keys.select{|k| k =~ /^@/ }
          explicit_attr = {}
          explicit_keys.each{|k| explicit_attr[k[1..-1]] = node_value[k]}
          node_attr.merge!(explicit_attr)
          explicit_keys.each{|k| node_value.delete(k) }

          node_value = node_value.delete("_content") || node_value
        end

        yield xml, key, hash[key], node_attr
      end

      xml.target!
    end

    # Deletes and returns an Array of keys stored under the :order! key of a given +hash+.
    # Defaults to return the actual keys of the Hash if no :order! key could be found.
    # Raises an ArgumentError in case the :order! Array does not match the Hash keys.
    def self.order(hash)
      order = hash.delete :order!
      order = hash.keys unless order.kind_of? ::Array

      # Ignore Explicit Attributes
      orderable = order.delete_if{|k| k =~ /^@/ }
      hashable = hash.keys.select{|k| !(k =~ /^@/) }

      missing, spurious = hashable - orderable, orderable - hashable
      raise ArgumentError, "Missing elements in :order! #{missing.inspect}" unless missing.empty?
      raise ArgumentError, "Spurious elements in :order! #{spurious.inspect}" unless spurious.empty?

      order
    end

  end
end
