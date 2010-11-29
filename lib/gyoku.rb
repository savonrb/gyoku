require "gyoku/version"
require "gyoku/hash"

module Gyoku

  def self.xml(object)
    case object
      when ::Hash  then Hash.to_xml object
      when ::Array then Array.to_xml object
      else              raise ArgumentError, "Expected kind_of Array || Hash"
    end
  end

end
