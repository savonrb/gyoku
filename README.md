Gyoku ![http://travis-ci.org/rubiii/gyoku](http://travis-ci.org/rubiii/gyoku.png)
=====

Gyoku translates Ruby Hashes to XML.

[Bugs](http://github.com/rubiii/gyoku/issues) | [Docs](http://rubydoc.info/gems/gyoku/frames)

Installation
------------

The gem is available through [Rubygems](http://rubygems.org/gems/gyoku) and can be installed via:

    $ gem install gyoku

An example
----------

    Gyoku.xml :find_user => { :id => 123, "wsdl:Key" => "api" }
    # => "<findUser><id>123</id><wsdl:Key>api</wsdl:Key></findUser>"

As you might notice, Gyoku follows a couple of conventions for translating Hashes into XML.

Conventions
-----------

### Hash keys

* Symbols are converted to lowerCamelCase Strings
* Strings are not converted and may contain namespaces

### Hash values

* DateTime objects are converted to xs:dateTime Strings
* Objects responding to :to_datetime (except Strings) are converted to xs:dateTime Strings
* TrueClass and FalseClass objects are converted to "true" and "false" Strings
* NilClass objects are converted to xsi:nil tags
* These conventions are also applied to the return value of objects responding to :call
* All other objects are converted to Strings using :to_s

Symbols are converted to lowerCamelCase?
----------------------------------------

That's the default. But you can use one of the other conversion formulas:

    Gyoku.convert_symbols_to :camelcase  # or one of [:none, :lower_camelcase]

or even define you own one:

    Gyoku.convert_symbols_to { |key| key.upcase }

Special characters
------------------

Gyoku escapes special characters unless the Hash key ends with an exclamation mark:

    Gyoku.xml :escaped => "<tag />", :not_escaped! => "<tag />"
    # => "<escaped>&lt;tag /&gt;</escaped><notEscaped><tag /></notEscaped>"

Self-closing tags
-----------------

Hash Keys ending with a forward slash create self-closing tags:

    Gyoku.xml :"self_closing/" => "", "selfClosing/" => nil
    # => "<selfClosing/><selfClosing/>"

Sort XML tags
-------------

In case you need the XML tags to be in a specific order, you can specify the order through an additional Array stored under an :order! key:

    Gyoku.xml :name => "Eve", :id => 1, :order! => [:id, :name]
    # => "<id>1</id><name>Eve</name>"

XML attributes
--------------

Adding XML attributes is rather ugly, but it can be done by specifying an additional Hash stored under an :attributes! key:

    Gyoku.xml :person => "Eve", :attributes! => { :person => { :id => 1 } }
    # => "<person id=\"1\">Eve</person>"
