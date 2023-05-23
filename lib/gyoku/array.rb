module Gyoku
  module Array
    module_function

    NESTED_ELEMENT_NAME = "element"

    # Builds XML and prettifies it if +pretty_print+ option is set to +true+
    def to_xml(array, key, escape_xml = true, attributes = {}, options = {})
      xml = build_xml(array, key, escape_xml, attributes, options)

      if options[:pretty_print] && options[:unwrap]
        Prettifier.prettify(xml, options)
      else
        xml
      end
    end

    # Translates a given +array+ to XML. Accepts the XML +key+ to add the elements to,
    # whether to +escape_xml+ and an optional Hash of +attributes+.
    def self.build_xml(array, key, escape_xml = true, attributes = {}, options = {})
      self_closing = options.delete(:self_closing)
      unwrap = unwrap?(options.fetch(:unwrap, false), key)

      iterate_with_xml array, key, attributes, options do |xml, item, attrs, index|
        if self_closing
          xml.tag!(key, attrs)
        else
          case item
          when ::Hash
            if unwrap
              xml << Hash.to_xml(item, options)
            else
              xml.tag!(key, attrs) { xml << Hash.build_xml(item, options) }
            end
          when ::Array
            xml.tag!(key, attrs) { xml << Array.build_xml(item, NESTED_ELEMENT_NAME) }
          when NilClass
            xml.tag!(key, "xsi:nil" => "true")
          else
            xml.tag!(key, attrs) { xml << XMLValue.create(item, escape_xml) }
          end
        end
      end
    end

    # Iterates over a given +array+ with a Hash of +attributes+ and yields a builder +xml+
    # instance, the current +item+, any XML +attributes+ and the current +index+.
    def iterate_with_xml(array, key, attributes, options, &block)
      xml = Builder::XmlMarkup.new
      unwrap = unwrap?(options.fetch(:unwrap, false), key)

      if unwrap
        xml.tag!(key, attributes) { iterate_array(xml, array, attributes, &block) }
      else
        iterate_array(xml, array, attributes, &block)
      end

      xml.target!
    end
    private_class_method :iterate_with_xml

    # Iterates over a given +array+ with a Hash of +attributes+ and yields a builder +xml+
    # instance, the current +item+, any XML +attributes+ and the current +index+.
    def iterate_array(xml, array, attributes, &block)
      array.each_with_index do |item, index|
        attrs = if item.respond_to?(:keys)
          item.each_with_object({}) do |v, st|
            k = v[0].to_s
            st[k[1..]] = v[1].to_s if k.start_with?("@")
          end
        else
          {}
        end
        yield xml, item, tag_attributes(attributes, index).merge(attrs), index
      end
    end
    private_class_method :iterate_array

    # Takes a Hash of +attributes+ and the +index+ for which to return attributes
    # for duplicate tags.
    def tag_attributes(attributes, index)
      return {} if attributes.empty?

      attributes.inject({}) do |hash, (key, value)|
        value = value[index] if value.is_a? ::Array
        value ? hash.merge(key => value) : hash
      end
    end
    private_class_method :tag_attributes

    def unwrap?(unwrap, key)
      unwrap.is_a?(::Array) ? unwrap.include?(key.to_sym) : unwrap
    end
    private_class_method :unwrap?
  end
end
