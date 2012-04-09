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

You can change the default conversion formula.

``` ruby
Gyoku.convert_symbols_to :camelcase  # or one of [:none, :lower_camelcase]

Gyoku.xml(:camel_case => "key")
# => "<CamelCase>key</CamelCase>"
```

And you can also define your own formula.

``` ruby
Gyoku.convert_symbols_to { |key| key.upcase }

Gyoku.xml(:upcase => "key")
# => "<UPCASE>key</UPCASE>"
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
