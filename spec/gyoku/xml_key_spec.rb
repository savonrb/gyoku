require "spec_helper"

describe Gyoku::XMLKey do

  describe ".create" do
    it "removes exclamation marks from the end of a String" do
      create("value!").should == "value"
    end

    it "removes forward slashes from the end of a String" do
      create("self-closing/").should == "self-closing"
    end

    it "does not convert snake_case Strings" do
      create("lower_camel_case").should == "lower_camel_case"
    end

    it "converts snake_case Symbols to lowerCamelCase Strings" do
      create(:lower_camel_case).should == "lowerCamelCase"
      create(:lower_camel_case!).should == "lowerCamelCase"
    end

    context "with :element_form_default set to :qualified and a :namespace" do
      it "adds the given namespace" do
        key = create :qualify, :element_form_default => :qualified, :namespace => :v1
        key.should == "v1:qualify"
      end

      it "does not add the given namespace if the key starts with a colon" do
        key = create ":qualify", :element_form_default => :qualified, :namespace => :v1
        key.should == "qualify"
      end

      it "adds a given :namespace after converting the key" do
        Gyoku::XMLKey.symbol_converter = :camelcase

        key = create :username, :element_form_default => :qualified, :namespace => :v1
        key.should == "v1:Username"
      end

      after { Gyoku::XMLKey.symbol_converter = :lower_camelcase }  #reset
    end
  end

  describe ".symbol_converter" do
    after { Gyoku::XMLKey.symbol_converter = :lower_camelcase }  #reset

    it "returns the default lower_camelcase converter" do
      Gyoku::XMLKey.symbol_converter.call("snake_case").should == "snakeCase"
    end

    it "accepts :lower_camelcase" do
      Gyoku::XMLKey.symbol_converter = :lower_camelcase
      Gyoku::XMLKey.create(:snake_case).should == "snakeCase"
    end

    it "accepts :camelcase" do
      Gyoku::XMLKey.symbol_converter = :camelcase
      Gyoku::XMLKey.create(:snake_case).should == "SnakeCase"
    end

    it "accepts :none" do
      Gyoku::XMLKey.symbol_converter = :none
      Gyoku::XMLKey.create(:snake_Case).should == "snake_Case"
    end

    it "allows to set a custom converter" do
      Gyoku::XMLKey.symbol_converter = Proc.new { |key| key.upcase }
      Gyoku::XMLKey.create(:snake_case).should == "SNAKE_CASE"
    end
  end

  def create(key, options = {})
    Gyoku::XMLKey.create key, options
  end

end
