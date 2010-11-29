require "spec_helper"

describe Gyoku do

  describe ".xml" do
    it "should translate a given Hash to XML" do
      Gyoku::Hash.expects(:to_xml).with(:id => 1)
      Gyoku.xml :id => 1
    end

    it "should translate a given Array to XML" do
      Gyoku::Array.expects(:to_xml).with([1, 2, 3])
      Gyoku.xml [1, 2, 3]
    end
  end

end
