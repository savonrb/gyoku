require "spec_helper"

describe Gyoku::XMLKey do
  include Gyoku::XMLKey

  describe "#to_xml_key" do
    it "should remove exclamation marks from the end of a String" do
      to_xml_key("value!").should == "value"
    end

    it "should remove forward slashes from the end of a String" do
      to_xml_key("self-closing/").should == "self-closing"
    end

    it "should not convert snake_case Strings" do
      to_xml_key("lower_camel_case").should == "lower_camel_case"
    end

    it "should convert snake_case Symbols to lowerCamelCase Strings" do
      to_xml_key(:lower_camel_case).should == "lowerCamelCase"
      to_xml_key(:lower_camel_case!).should == "lowerCamelCase"
    end
  end

end
