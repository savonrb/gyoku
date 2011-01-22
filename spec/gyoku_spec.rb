require "spec_helper"

describe Gyoku do

  describe ".xml" do
    it "should translate a given Hash to XML" do
      Gyoku::Hash.expects(:to_xml).with({:id => 1}, :element_form_default => :qualified)
      Gyoku.xml({ :id => 1 }, :element_form_default => :qualified)
    end
  end

end
