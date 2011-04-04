require "spec_helper"

describe Gyoku::XMLKey do

  describe ".create" do
    it "should remove exclamation marks from the end of a String" do
      create("value!").should == "value"
    end

    it "should remove forward slashes from the end of a String" do
      create("self-closing/").should == "self-closing"
    end

    it "should not convert snake_case Strings" do
      create("lower_camel_case").should == "lower_camel_case"
    end

    it "should convert snake_case Symbols to lowerCamelCase Strings" do
      create(:lower_camel_case).should == "lowerCamelCase"
      create(:lower_camel_case!).should == "lowerCamelCase"
    end

    context "with :element_form_default set to :qualified and a :namespace" do
      it "should add the given namespace" do
        key = create :qualify, :element_form_default => :qualified, :namespace => :v1
        key.should == "v1:qualify"
      end

      it "should not add the given namespace if the key starts with a colon" do
        key = create ":qualify", :element_form_default => :qualified, :namespace => :v1
        key.should == "qualify"
      end
    end
  end

  describe ".symbol_converter" do
    after { Gyoku::XMLKey.symbol_converter = :lower_camelcase }  #reset

    it "should return the default lower_camelcase converter" do
      Gyoku::XMLKey.symbol_converter.call("snake_case").should == "snakeCase"
    end

    it "should accept :lower_camelcase" do
      Gyoku::XMLKey.symbol_converter = :lower_camelcase
      Gyoku::XMLKey.create(:snake_case).should == "snakeCase"
    end

    it "should accept :camelcase" do
      Gyoku::XMLKey.symbol_converter = :camelcase
      Gyoku::XMLKey.create(:snake_case).should == "SnakeCase"
    end

    it "should accept :none" do
      Gyoku::XMLKey.symbol_converter = :none
      Gyoku::XMLKey.create(:snake_Case).should == "snake_Case"
    end

    it "should allow to set a custom converter" do
      Gyoku::XMLKey.symbol_converter = Proc.new { |key| key.upcase }
      Gyoku::XMLKey.create(:snake_case).should == "SNAKE_CASE"
    end
  end

  def create(key, options = {})
    Gyoku::XMLKey.create key, options
  end

end
