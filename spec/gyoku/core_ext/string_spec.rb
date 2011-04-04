require "spec_helper"

describe String do

  describe "#lower_camelcase" do
    it "converts a snakecase String to lowerCamelCase" do
      "lower_camel_case".lower_camelcase.should == "lowerCamelCase"
    end
  end

  describe "#camelcase" do
    it "converts a snakecase String to CamelCase" do
      "camel_case".camelcase.should == "CamelCase"
    end
  end

end
