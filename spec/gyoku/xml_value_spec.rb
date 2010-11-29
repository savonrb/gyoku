require "spec_helper"

describe Gyoku::XMLValue do
  include Gyoku::XMLValue

  let(:datetime) { DateTime.new 2012, 03, 22, 16, 22, 33 }
  let(:datetime_string) { "2012-03-22T16:22:33+00:00" }
  
  describe "#to_xml_value" do
    context "for DateTime objects" do
      it "should return an xs:dateTime compliant String" do
        to_xml_value(datetime).should == datetime_string
      end
    end

    it "should return the String value and escape special characters" do
      to_xml_value("string").should == "string"
      to_xml_value("<tag>").should == "&lt;tag&gt;"
      to_xml_value("at&t").should == "at&amp;t"
      to_xml_value('"quotes"').should == "&quot;quotes&quot;"
    end

    it "should just return the String value without escaping special characters" do
      to_xml_value("<tag>", false).should == "<tag>"
    end

    it "returns an xs:dateTime compliant String for Objects responding to :to_datetime" do
      singleton = Object.new
      def singleton.to_datetime
        DateTime.new(2012, 03, 22, 16, 22, 33)
      end

      to_xml_value(singleton).should == "2012-03-22T16:22:33+00:00"
    end

    it "calls to_s unless the Object responds to to_datetime" do
      to_xml_value("value").should == "value"
    end
  end

end
