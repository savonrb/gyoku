require "cgi"

module Gyoku
  module XMLValue

    # xs:dateTime format.
    XS_DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S%Z"

    # Converts a given +object+ to an XML value.
    def to_xml_value(object, escape_xml = true)
      if DateTime === object
        object.strftime XS_DATETIME_FORMAT
      elsif String === object
        escape_xml ? CGI.escapeHTML(object) : object
      elsif object.respond_to?(:to_datetime)
        to_xml_value object.to_datetime
      elsif object.respond_to?(:call)
        to_xml_value object.call
      else
        object.to_s
      end
    end

  end
end
