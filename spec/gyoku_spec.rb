require "spec_helper"

describe Gyoku do

  describe ".xml" do
    it "translates a given Hash to XML" do
      Gyoku.xml({ :id => 1 }, :element_form_default => :qualified).should == "<id>1</id>"
    end
  end

  describe ".configure" do
    it "yields the Gyoku module" do
      Gyoku.configure { |config| config.should respond_to(:convert_symbols_to) }
    end
  end

  describe ".convert_symbols_to" do
    after { Gyoku.convert_symbols_to(:lower_camelcase) }  # reset

    it "accepts a predefined formula" do
      Gyoku.convert_symbols_to(:camelcase)
      Gyoku::XMLKey.create(:snake_case).should == "SnakeCase"
    end

    it "accepts a block" do
      Gyoku.convert_symbols_to { |key| key.upcase }
      Gyoku::XMLKey.create(:snake_case).should == "SNAKE_CASE"
    end
  end

end
