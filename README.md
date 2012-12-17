Gyoku [![Build Status](https://secure.travis-ci.org/rubiii/gyoku.png)](http://travis-ci.org/rubiii/gyoku)
=====

##### Translates Ruby Hashes to XML

Gyoku is available through [Rubygems](http://rubygems.org/gems/gyoku) and can
be installed via:

```
$ gem install gyoku
```

Gyoku is based on a few conventions.

``` ruby
Gyoku.xml(:find_user => { :id => 123, "v1:Key" => "api" })
# => "<findUser><id>123</id><v1:Key>api</v1:Key></findUser>"
```


Hash keys
---------

Hash key Symbols are converted to lowerCamelCase Strings.

``` ruby
Gyoku.xml(:lower_camel_case => "key")
# => "<lowerCamelCase>key</lowerCamelCase>"
```

You can change the default conversion formula to :camelcase, :upcase or :none.

``` ruby
Gyoku.xml(:camel_case => "key", :key_converter => :camelcase)
# => "<CamelCase>key</CamelCase>"
```

Hash key Strings are not converted and may contain namespaces.

``` ruby
Gyoku.xml("XML" => "key")
# => "<XML>key</XML>"
```


Hash values
-----------

* DateTime objects are converted to xs:dateTime Strings
* Objects responding to :to_datetime (except Strings) are converted to xs:dateTime Strings
* TrueClass and FalseClass objects are converted to "true" and "false" Strings
* NilClass objects are converted to xsi:nil tags
* These conventions are also applied to the return value of objects responding to :call
* All other objects are converted to Strings using :to_s


Special characters
------------------

Gyoku escapes special characters unless the Hash key ends with an exclamation mark.

``` ruby
Gyoku.xml(:escaped => "<tag />", :not_escaped! => "<tag />")
# => "<escaped>&lt;tag /&gt;</escaped><notEscaped><tag /></notEscaped>"
```


Self-closing tags
-----------------

Hash Keys ending with a forward slash create self-closing tags.

``` ruby
Gyoku.xml(:"self_closing/" => "", "selfClosing/" => nil)
# => "<selfClosing/><selfClosing/>"
```


Sort XML tags
-------------

In case you need the XML tags to be in a specific order, you can specify the order through an additional Array stored under an `:order!` key.

``` ruby
Gyoku.xml(:name => "Eve", :id => 1, :order! => [:id, :name])
# => "<id>1</id><name>Eve</name>"
```


XML attributes
--------------

Adding XML attributes is rather ugly, but it can be done by specifying an additional Hash stored under an `:attributes!` key.

``` ruby
Gyoku.xml(:person => "Eve", :attributes! => { :person => { :id => 1 } })
# => "<person id=\"1\">Eve</person>"
```

Explicit XML Attributes
-----------------------
In addition to using :attributes!, you may also specify attributes with key names beginning with "@". 

Since you'll need to set the attribute within the hash containing the node's contents, a :content! key can be used to explicity set the content of the node. The ":content!" value may be a String, Hash, or Array.

This is particularly useful for self-closing tags.

**Using :attributes!**

``` ruby
Gyoku.xml(
  "foo/" => "", 
  :attributes! => {
    "foo/" => {
      "bar" => "1", 
      "biz" => "2", 
      "baz" => "3"
    }
  }
)
# => "<foo baz=\"3\" bar=\"1\" biz=\"2\"/>"
```

**Using "@" keys and ":content!"**

``` ruby
Gyoku.xml(
  "foo/" => {
    :@bar => "1",
    :@biz => "2",
    :@baz => "3",
    :content! => ""
  })
# => "<foo baz=\"3\" bar=\"1\" biz=\"2\"/>"
```
This seems a bit more explicit with the attributes rather than having to maintain a hash of attributes.

For backward compatibility, :attributes! will still work. However, "@" keys will override :attributes! keys if there is a conflict.

``` ruby
Gyoku.xml(:person => {:content! => "Adam", :@id! => 0})
# => "<person id=\"0\">Adam</person>"
```

Example with ":content!", :attributes! and "@" keys
--------------------------------------------------
``` ruby
Gyoku.xml({ 
  :subtitle => { 
    :@lang => "en", 
    :content! => "It's Godzilla!" 
  }, 
  :attributes! => { :subtitle => { "lang" => "jp" } } 
}
# => "<subtitle lang=\"en\">It's Godzilla!</subtitle>"
```

The example above shows an example of how you can use all three at the same time. 

Notice that we have the attribute "lang" defined twice.
The "@lang" value takes precedence over the :attribute![:subtitle]["lang"] value.
