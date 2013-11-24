require "spec_helper"

describe Gyoku::Hash do

  describe ".to_xml" do
    describe "returns SOAP request compatible XML" do
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

    it "converts Hash key Symbols to lowerCamelCase" do
      to_xml(:find_or_create => "user").should == "<findOrCreate>user</findOrCreate>"
    end

    it "does not convert Hash key Strings" do
      to_xml("find_or_create" => "user").should == "<find_or_create>user</find_or_create>"
    end

    it "converts DateTime objects to xs:dateTime compliant Strings" do
      to_xml(:before => DateTime.new(2012, 03, 22, 16, 22, 33)).
        should == "<before>2012-03-22T16:22:33+00:00</before>"
    end

    it "converts Objects responding to to_datetime to xs:dateTime compliant Strings" do
      singleton = Object.new
      def singleton.to_datetime
        DateTime.new(2012, 03, 22, 16, 22, 33)
      end

      to_xml(:before => singleton).should == "<before>2012-03-22T16:22:33+00:00</before>"
    end

    it "calls to_s on Strings even if they respond to to_datetime" do
      singleton = "gorilla"
      def singleton.to_datetime
        DateTime.new(2012, 03, 22, 16, 22, 33)
      end

      to_xml(:name => singleton).should == "<name>gorilla</name>"
    end

    it "properly serializes nil values" do
      to_xml(:some => nil).should == '<some xsi:nil="true"/>'
    end

    it "creates self-closing tags for Hash keys ending with a forward slash" do
      to_xml("self-closing/" => nil).should == '<self-closing/>'
    end

    it "calls to_s on any other Object" do
      [666, true, false].each do |object|
        to_xml(:some => object).should == "<some>#{object}</some>"
      end
    end

    it "defaults to escape special characters" do
      result = to_xml(:some => { :nested => "<tag />" }, :tag => "<tag />")
      result.should include("<tag>&lt;tag /&gt;</tag>")
      result.should include("<some><nested>&lt;tag /&gt;</nested></some>")
    end

    it "does not escape special characters for keys marked with an exclamation mark" do
      result = to_xml(:some => { :nested! => "<tag />" }, :tag! => "<tag />")
      result.should include("<tag><tag /></tag>")
      result.should include("<some><nested><tag /></nested></some>")
    end

    it "preserves the order of Hash keys and values specified through :order!" do
      hash = { :find_user => { :name => "Lucy", :id => 666, :order! => [:id, :name] } }
      result = "<findUser><id>666</id><name>Lucy</name></findUser>"
      to_xml(hash).should == result

      hash = { :find_user => { :mname => "in the", :lname => "Sky", :fname => "Lucy", :order! => [:fname, :mname, :lname] } }
      result = "<findUser><fname>Lucy</fname><mname>in the</mname><lname>Sky</lname></findUser>"
      to_xml(hash).should == result
    end

    it "raises if the :order! Array is missing Hash keys" do
      hash = { :name => "Lucy", :id => 666, :order! => [:name] }
      lambda { to_xml(hash) }.should raise_error(ArgumentError, "Missing elements in :order! [:id]")
    end

    it "raises if the :order! Array contains missing Hash keys" do
      hash = { :by_name => { :first_name => "Lucy", :last_name => "Sky", :order! => [:first_name, :middle_name, :last_name] } }
      lambda { to_xml(hash) }.should raise_error(ArgumentError, "Spurious elements in :order! [:middle_name]")
    end

    it "adds attributes to Hash keys specified through :attributes!" do
      hash = { :find_user => { :person => "Lucy", :attributes! => { :person => { :id => 666 } } } }
      result = '<findUser><person id="666">Lucy</person></findUser>'
      to_xml(hash).should == result

      hash = { :find_user => { :person => "Lucy", :attributes! => { :person => { :id => 666, :city => "Hamburg" } } } }
      to_xml(hash).should include('id="666"', 'city="Hamburg"')
    end

    it "adds attributes to duplicate Hash keys specified through :attributes!" do
      hash = { :find_user => { :person => ["Lucy", "Anna"], :attributes! => { :person => { :id => [1, 3] } } } }
      result = '<findUser><person id="1">Lucy</person><person id="3">Anna</person></findUser>'
      to_xml(hash).should == result

      hash = { :find_user => { :person => ["Lucy", "Anna"], :attributes! => { :person => { :active => "true" } } } }
      result = '<findUser><person active="true">Lucy</person><person active="true">Anna</person></findUser>'
      to_xml(hash).should == result
    end

    it "skips attribute for element without attributes if there are fewer attributes than elements" do
      hash = { :find_user => { :person => ["Lucy", "Anna", "Beth"], :attributes! => { :person => { :id => [1, 3] } } } }
      result = '<findUser><person id="1">Lucy</person><person id="3">Anna</person><person>Beth</person></findUser>'
      to_xml(hash).should == result
    end

    it "adds attributes to self-closing tags" do
      hash = {
        "category/" => "",
        :attributes! => { "category/" => { :id => 1 }  }
      }

      to_xml(hash).should == '<category id="1"/>'
    end

    it "recognizes @attribute => value along :attributes!" do
      hash = {
        "category" => {
          :content! => "users",
          :@id => 1
        }
      }
      to_xml(hash).should == '<category id="1">users</category>'
    end

    it "recognizes @attribute => value along :attributes! in selfclosed tags" do
      hash = {
        "category/" => {
          :@id => 1
        }
      }
      to_xml(hash).should == '<category id="1"/>'
    end

    it ":@attribute => value takes over :attributes!" do
      hash = {
        "category/" => {
          :@id => 1
        },
        :attributes! => {
          "category/" => {
            'id' => 2, # will be ignored
            'type' => 'admins'
          }
        }
      }
      # attribute order is undefined
      ['<category id="1" type="admins"/>','<category type="admins" id="1"/>'].should include to_xml(hash)

      # with symbols
      hash = {
        "category/" => {
          :@id => 1
        },
        :attributes! => {
          "category/" => {
            :id => 2, # will be ignored
            :type => 'admins'
          }
        }
      }
      ['<category id="1" type="admins"/>','<category type="admins" id="1"/>'].should include to_xml(hash)
    end

    it "recognizes :content! => value as tag content" do
      hash = {
        "category" => {
          :content! => "users"
        }
      }
      to_xml(hash).should == "<category>users</category>"
    end

    it "recognizes :content! => value as tag content with value Fixnum" do
      hash = {
        "category" => {
          :content! => 666
        }
      }
      to_xml(hash).should == "<category>666</category>"
    end

    it "recognizes :content! => value as tag content with value true" do
      hash = {
        "category" => {
          :content! => true
        }
      }
      to_xml(hash).should == "<category>true</category>"
    end

    it "recognizes :content! => value as tag content with value false" do
      hash = {
        "category" => {
          :content! => false
        }
      }
      to_xml(hash).should == "<category>false</category>"
    end

    it "recognizes :content! => value as tag content with value DateTime" do
      hash = {
        "before" => {
          :content! => DateTime.new(2012, 03, 22, 16, 22, 33)
        }
      }
      to_xml(hash).should == "<before>2012-03-22T16:22:33+00:00</before>"
    end

    it "ignores :content! if self-closing mark present" do
      hash = {
        "category/" => {
          :content! => "users"
        }
      }
      to_xml(hash).should == "<category/>"
    end

    it "recognizes array of attributes" do
      hash = {
        "category" => [{:@name => 'one'}, {:@name => 'two'}]
      }
      to_xml(hash).should == '<category name="one"></category><category name="two"></category>'

      # issue #31.
      hash = {
        :order! => ['foo', 'bar'],
        'foo' => { :@foo => 'foo' },
        'bar' => { :@bar => 'bar', 'baz' => { } },
      }
      to_xml(hash).should == '<foo foo="foo"></foo><bar bar="bar"><baz></baz></bar>'
    end

    it "recognizes array of attributes with content in each" do
      hash = {
        "foo" => [{:@name => "bar", :content! => 'gyoku'}, {:@name => "baz", :@some => "attr", :content! => 'rocks!'}]
      }

      [
        '<foo name="bar">gyoku</foo><foo name="baz" some="attr">rocks!</foo>',
        '<foo name="bar">gyoku</foo><foo some="attr" name="baz">rocks!</foo>'
      ].should include to_xml(hash)
    end

    it "recognizes array of attributes but ignores content in each if selfclosing" do
      hash = {
        "foo/" => [{:@name => "bar", :content! => 'gyoku'}, {:@name => "baz", :@some => "attr", :content! => 'rocks!'}]
      }

      [
        '<foo name="bar"/><foo name="baz" some="attr"/>',
        '<foo name="bar"/><foo some="attr" name="baz"/>'
      ].should include to_xml(hash)
    end

    it "recognizes array of attributes with selfclosing tag" do
      hash = {
        "category/" => [{:@name => 'one'}, {:@name => 'two'}]
      }
      to_xml(hash).should == '<category name="one"/><category name="two"/>'
    end

    context "with :element_form_default set to :qualified and a :namespace" do
      it "adds the given :namespace to every element" do
        hash = { :first => { "first_name" => "Lucy" }, ":second" => { :":first_name" => "Anna" }, "v2:third" => { "v2:firstName" => "Danie" } }
        result = to_xml hash, :element_form_default => :qualified, :namespace => :v1

        result.should include(
          "<v1:first><v1:first_name>Lucy</v1:first_name></v1:first>",
          "<second><firstName>Anna</firstName></second>",
          "<v2:third><v2:firstName>Danie</v2:firstName></v2:third>"
        )
      end

      it "adds given :namespace to every element in an array" do
        hash = { :array => [ :first  => "Lucy", :second => "Anna" ]}
        result = to_xml hash, :element_form_default => :qualified, :namespace => :v1

        result.should include("<v1:array>", "<v1:first>Lucy</v1:first>", "<v1:second>Anna</v1:second>")
      end
    end

    it "does not remove special keys from the original Hash" do
      hash = {
        :persons => {
          :first => "Lucy",
          :second => "Anna",
          :order! => [:second, :first],
          :attributes! => { :first => { :first => true } }
        },
        :countries => [:de, :us],
        :order! => [:countries, :persons],
        :attributes! => { :countries => { :array => true } }
      }

      to_xml(hash)

      hash.should == {
        :persons => {
          :first => "Lucy",
          :second => "Anna",
          :order! => [:second, :first],
          :attributes! => { :first => { :first => true } }
        },
        :countries => [:de, :us],
        :order! => [:countries, :persons],
        :attributes! => { :countries => { :array => true } }
      }
    end
  end

  it "doesn't modify original hash parameter by deleting its attribute keys" do
    hash = { :person => {:name => "Johnny", :surname => "Bravo", :"@xsi:type" => "People"} }
    to_xml(hash)
    hash.should == {:person=>{:name=>"Johnny", :surname=>"Bravo", :"@xsi:type"=>"People"}}
  end

  def to_xml(hash, options = {})
    Gyoku::Hash.to_xml hash, options
  end

end
