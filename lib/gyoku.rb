require "gyoku/version"
require "gyoku/hash"

module Gyoku

  # Translates a given +hash+ with +options+ to XML.
  def self.xml(hash, options = {})
    Hash.to_xml hash, options
  end

end
