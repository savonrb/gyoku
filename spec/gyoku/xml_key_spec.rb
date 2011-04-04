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

  def create(key, options = {})
    Gyoku::XMLKey.create key, options
  end

end
