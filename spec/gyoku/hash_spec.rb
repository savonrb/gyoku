require "spec_helper"

describe Gyoku::Hash do

  describe ".to_xml" do
    describe "should return SOAP request compatible XML" do
      it "for a simple Hash" do
        to_xml(:some => "user").should == "<some>user</some>"
      end

      it "for a nested Hash" do
        to_xml(:some => { :new => "user" }).should == "<some><new>user</new></some>"
      end

      it "for a Hash with multiple keys" do
        to_xml(:all => "users", :before => "whatever").should include(
          "<all>users</all>",
          "<before>whatever</before>"
        )
      end

      it "for a Hash containing an Array" do
        to_xml(:some => ["user", "gorilla"]).should == "<some>user</some><some>gorilla</some>"
      end

      it "for a Hash containing an Array of Hashes" do
        to_xml(:some => [{ :new => "user" }, { :old => "gorilla" }]).
          should == "<some><new>user</new></some><some><old>gorilla</old></some>"
      end
    end

    it "should convert Hash key Symbols to lowerCamelCase" do
      to_xml(:find_or_create => "user").should == "<findOrCreate>user</findOrCreate>"
    end

    it "should not convert Hash key Strings" do
      to_xml("find_or_create" => "user").should == "<find_or_create>user</find_or_create>"
    end

    it "should convert DateTime objects to xs:dateTime compliant Strings" do
      to_xml(:before => DateTime.new(2012, 03, 22, 16, 22, 33)).
        should == "<before>2012-03-22T16:22:33+00:00</before>"
    end

    it "should convert Objects responding to to_datetime to xs:dateTime compliant Strings" do
      singleton = Object.new
      def singleton.to_datetime
        DateTime.new(2012, 03, 22, 16, 22, 33)
      end

      to_xml(:before => singleton).should == "<before>2012-03-22T16:22:33+00:00</before>"
    end

    it "should call to_s on Strings even if they respond to to_datetime" do
      object = "gorilla"
      object.expects(:to_datetime).never

      to_xml(:name => object).should == "<name>gorilla</name>"
    end

    it "should properly serialize nil values" do
      to_xml(:some => nil).should == '<some xsi:nil="true"/>'
    end

    it "should create self-closing tags for Hash keys ending with a forward slash" do
      to_xml("self-closing/" => nil).should == '<self-closing/>'
    end

    it "should call to_s on any other Object" do
      [666, true, false].each do |object|
        to_xml(:some => object).should == "<some>#{object}</some>"
      end
    end

    it "should default to escape special characters" do
      result = to_xml(:some => { :nested => "<tag />" }, :tag => "<tag />")
      result.should include("<tag>&lt;tag /&gt;</tag>")
      result.should include("<some><nested>&lt;tag /&gt;</nested></some>")
    end

    it "should not escape special characters for keys marked with an exclamation mark" do
      result = to_xml(:some => { :nested! => "<tag />" }, :tag! => "<tag />")
      result.should include("<tag><tag /></tag>")
      result.should include("<some><nested><tag /></nested></some>")
    end

    it "should preserve the order of Hash keys and values specified through :order!" do
      hash = { :find_user => { :name => "Lucy", :id => 666, :order! => [:id, :name] } }
      result = "<findUser><id>666</id><name>Lucy</name></findUser>"
      to_xml(hash).should == result

      hash = { :find_user => { :mname => "in the", :lname => "Sky", :fname => "Lucy", :order! => [:fname, :mname, :lname] } }
      result = "<findUser><fname>Lucy</fname><mname>in the</mname><lname>Sky</lname></findUser>"
      to_xml(hash).should == result
    end

    it "should raise an error if the :order! Array does not match the Hash keys" do
      hash = { :name => "Lucy", :id => 666, :order! => [:name] }
      lambda { to_xml(hash) }.should raise_error(ArgumentError)

      hash = { :by_name => { :name => "Lucy", :lname => "Sky", :order! => [:mname, :name] } }
      lambda { to_xml(hash) }.should raise_error(ArgumentError)
    end

    it "should add attributes to Hash keys specified through :attributes!" do
      hash = { :find_user => { :person => "Lucy", :attributes! => { :person => { :id => 666 } } } }
      result = '<findUser><person id="666">Lucy</person></findUser>'
      to_xml(hash).should == result

      hash = { :find_user => { :person => "Lucy", :attributes! => { :person => { :id => 666, :city => "Hamburg" } } } }
      to_xml(hash).should include('id="666"', 'city="Hamburg"')
    end

    it "should add attributes to duplicate Hash keys specified through :attributes!" do
      hash = { :find_user => { :person => ["Lucy", "Anna"], :attributes! => { :person => { :id => [1, 3] } } } }
      result = '<findUser><person id="1">Lucy</person><person id="3">Anna</person></findUser>'
      to_xml(hash).should == result

      hash = { :find_user => { :person => ["Lucy", "Anna"], :attributes! => { :person => { :active => "true" } } } }
      result = '<findUser><person active="true">Lucy</person><person active="true">Anna</person></findUser>'
      to_xml(hash).should == result
    end

    context "with :element_form_default set to :qualified and a :namespace" do
      it "should add the given :namespace to every element" do
        hash = { :first => { "first_name" => "Luvy" }, ":second" => { :":first_name" => "Anna" }, "v2:third" => { "v2:firstName" => "Danie" } }
        result = to_xml hash, :element_form_default => :qualified, :namespace => :v1

        result.should include(
          "<v1:first><v1:first_name>Luvy</v1:first_name></v1:first>",
          "<second><firstName>Anna</firstName></second>",
          "<v2:third><v2:firstName>Danie</v2:firstName></v2:third>"
        )
      end
      
      it "should add given :namespace to every element in an array" do
        hash = { :array => [ :first  => "Luvy", :second => "Anna" ]}
        result = to_xml hash, :element_form_default => :qualified, :namespace => :v1

        result.should include(
          "<v1:array><v1:first>Luvy</v1:first><v1:second>Anna</v1:second></v1:array>"
        )
      end
      
    end
  end

  def to_xml(hash, options = {})
    Gyoku::Hash.to_xml hash, options
  end

end
