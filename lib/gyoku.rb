# STDLIB
require "rexml/document"
require "cgi"
require "date"

# Gems
require "builder"

require "gyoku/version"
require "gyoku/prettifier"
require "gyoku/hash"
require "gyoku/array"
require "gyoku/xml_key"
require "gyoku/xml_value"

module Gyoku

  # Converts a given Hash +key+ with +options+ into an XML tag.
  def self.xml_tag(key, options = {})
    XMLKey.create(key, options)
  end

  # Translates a given +hash+ with +options+ to XML.
  def self.xml(hash, options = {})
    Hash.to_xml hash.dup, options
  end

end
