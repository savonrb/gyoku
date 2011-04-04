require "spec_helper"

describe Gyoku::XMLValue do

  let(:datetime) { DateTime.new 2012, 03, 22, 16, 22, 33 }
  let(:datetime_string) { "2012-03-22T16:22:33+00:00" }

  describe ".create" do
    context "for DateTime objects" do
      it "should return an xs:dateTime compliant String" do
        create(datetime).should == datetime_string
      end
    end

    it "should return the String value and escape special characters" do
      create("string").should == "string"
      create("<tag>").should == "&lt;tag&gt;"
      create("at&t").should == "at&amp;t"
      create('"quotes"').should == "&quot;quotes&quot;"
    end

    it "should just return the String value without escaping special characters" do
      create("<tag>", false).should == "<tag>"
    end

    it "should return an xs:dateTime compliant String for Objects responding to #to_datetime" do
      singleton = Object.new
      def singleton.to_datetime
        DateTime.new 2012, 03, 22, 16, 22, 33
      end

      create(singleton).should == "2012-03-22T16:22:33+00:00"
    end

    it "should #call Proc objects and convert their return value" do
      object = lambda { DateTime.new 2012, 03, 22, 16, 22, 33 }
      create(object).should == "2012-03-22T16:22:33+00:00"
    end

    it "should call #to_s unless the Object responds to #to_datetime" do
      create("value").should == "value"
    end
  end

  def create(object, escape_xml = true)
    Gyoku::XMLValue.create object, escape_xml
  end

end
