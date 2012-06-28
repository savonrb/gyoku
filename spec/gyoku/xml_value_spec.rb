require "spec_helper"

describe Gyoku::XMLValue do

  describe ".create" do
    context "for DateTime objects" do
      it "returns an xs:dateTime compliant String" do
        create(DateTime.new(2012, 03, 22, 16, 22, 33)).should == "2012-03-22T16:22:33+00:00"
      end
    end

    context "for Date objects" do
      it "returns an xs:date compliant String" do
        create(Date.new(2012, 03, 22)).should == "2012-03-22"
      end
    end

    context "for Time objects" do
      it "returns an xs:time compliant String" do
        create(Time.local(2012, 03, 22, 16, 22, 33)).should == "16:22:33"
      end
    end

    it "returns the String value and escapes special characters" do
      create("string").should == "string"
      create("<tag>").should == "&lt;tag&gt;"
      create("at&t").should == "at&amp;t"
      create('"quotes"').should == "&quot;quotes&quot;"
    end

    it "returns the String value without escaping special characters" do
      create("<tag>", false).should == "<tag>"
    end

    it "returns an xs:dateTime compliant String for Objects responding to #to_datetime" do
      singleton = Object.new
      def singleton.to_datetime
        DateTime.new 2012, 03, 22, 16, 22, 33
      end

      create(singleton).should == "2012-03-22T16:22:33+00:00"
    end

    it "calls Proc objects and converts their return value" do
      object = lambda { DateTime.new 2012, 03, 22, 16, 22, 33 }
      create(object).should == "2012-03-22T16:22:33+00:00"
    end

    it "calls #to_s unless the Object responds to #to_datetime" do
      create("value").should == "value"
    end
  end

  def create(object, escape_xml = true)
    Gyoku::XMLValue.create object, escape_xml
  end

end
