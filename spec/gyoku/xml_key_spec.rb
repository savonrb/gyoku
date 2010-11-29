require "spec_helper"

describe Gyoku::XMLKey do
  include Gyoku::XMLKey

  describe "#to_xml_key" do
    it "removes exclamation marks from the end of a String" do
      to_xml_key("value").should == "value"
      to_xml_key("value!").should == "value"
    end

    it "converts snake_case Symbols to lowerCamelCase Strings" do
      to_xml_key(:lower_camel_case).should == "lowerCamelCase"
      to_xml_key(:lower_camel_case!).should == "lowerCamelCase"
    end
  end

end
