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

    context "with :element_form_default set to :qualified and a :namespace" do
      it "should add the given namespace" do
        key = to_xml_key :qualify, :element_form_default => :qualified, :namespace => :v1
        key.should == "v1:qualify"
      end

      it "should not add the given namespace if the key starts with a colon" do
        key = to_xml_key ":qualify", :element_form_default => :qualified, :namespace => :v1
        key.should == "qualify"
      end
    end
  end

end
