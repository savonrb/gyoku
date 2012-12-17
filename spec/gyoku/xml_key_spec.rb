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
        key = create :username, :element_form_default => :qualified, :namespace => :v1, :key_converter => :camelcase
        key.should == "v1:Username"
      end
    end
  end

  def create(key, options = {})
    Gyoku::XMLKey.create(key, options)
  end

end
