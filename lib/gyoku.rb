require "gyoku/version"
require "gyoku/hash"

module Gyoku

  def self.xml(hash)
    Hash.to_xml hash
  end

end
