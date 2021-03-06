# ApidocoDsl

This gem provides a DSL wrapper around the excellent [Apidoco Gem](https://github.com/72pulses/apidoco) for Ruby on Rails projects. The DSL is heavily inspired by the one provided by [Apipie](https://github.com/Apipie/apipie-rails), but it was developed from scratch. In our opinion, the Apidoco system is more flexible, and it's output is prettier than Apipie. The one thing it was lacking was a good DSL to produce the JSON files that make up its documentation output. That's where this gem comes in. Instead of writing JSON files by hand, using this gem you can write your documentation directly in to your code _as code_, which is later parsed and converted into the JSON files that feed the Apidoco engine.

## Compatibility with Apidoco

This DSL gem was written against the 1.5.4 version of the Apidoco gem. Later versions of Apidoco may introduce breaking changes with this gem, but we'll do our best to keep it up to date. One important point with regards to compatibility is that this gem renders Apidoco's resource generator, (`rails g apidoco resource`), unnecessary, unless there really is certain documentation you'd rather write the raw JSON file for. Using this gem, documentation that you write into your code will automatically be placed in the right locations for the Apidoco engine.

## Generating documentation

Once you've written your documentation into your code, it has to be parsed and written out to the appropriate Apidoco directory in JSON format. This gem provides a generator for this purpose that is invoked this way:

```bash
rails g apidoco_dsl:documentation
```

## Writing Documentation

### Where to write it

As mentioned before, this gem allows you to write documentation for your code using code. There are a couple ways you can do this, depending upon the needs of your project and how much you want to intermingle your functional code with your documentation.

#### Inline with the methods they document

By including the ApidocoDsl module in to the classes you want to document, you can write your documentation in the same file with the code it documents:

```ruby
class MyApiController < ApplicationController
  require 'apidoco_dsl'
  extend ApidocoDsl

  namespace "V1"
  resource :widgets

  api_doc do
    ...
  end
  def show
    ...
  end
end
```

#### In a separate class

Unlike systems like Apipie, with Apidoco and this gem, there is no inherent programmatic link between documentation and the classes/methods being documented. Because of this, it is possible, (and perhaps even preferable), to define all of your documentation in locations and classes that are entirely separate from the code they document. You are free to organize your documentation files however it makes sense to you.

```ruby
module ApiDocs
  class MyResource
    extend ApidocoDsl
    extend ActiveSupport::Concern

    api_doc do
      ...
    end
  end
end
```

### The DSL

At the most basic level, ApidocoDsl is used for writing documentation about the individual endpoints of your API. Doing so starts with defining an `api_doc` block. Below is a "full" doc block:

```ruby
api_doc do
  published true
  name "Do Something"
  description "Does Something"
  endpoint "/v1/do_something/"
  http_method 'POST'
  header({ 'Content-Type' => 'application/json', 'Authentication' => "Bearer <token>" })

  param :thing1, type: 'String',  desc: 'The first thing', notes: "Introduced by the Cat In The Hat", required: true
  param :thing2, type: 'Integer', desc: 'The second thing', notes: "Comes with Thing 1"

  example_request do
    {
      thing1: "This is the first thing",
      thing2: 42
    }
  end

  example_response path: example_root + '/create_response.json'

  returns code: :created do
    property :thing_id, type: 'Integer', desc: "The thing's ID", notes: "Will be a number"
    param_group :carrier_connection_response
  end
end
```

Note in the example above that `example_root` is a variable defined above this definition, and not actually part of the ApidocoDsl.

Everything inside the block is considered documentation for the endpoint. It may be helpful to read the [Apidoco documentation](https://github.com/72pulses/apidoco), for context on some of these, but each method is described below.

#### published

Whether or not this documentation should be 'published', that is, visible on the documentation site. By default, documentation is _not_ published. Calling this method with an argument of `true`, will make it visible.

#### name

This is the name that will be displayed on the documentation page to identify this endpoint, both as a header and in the navigation. It can be anything you want, but obviously should actually identify the endpoint being documented. It takes a string.

#### description

A longer-form description of the endpoint. This method takes either a string _or_ a path argument. Given a string, it will simply display that string. Given a path, it will parse the provided file, (as Markdown), and use the result as the description for the endpoint.

#### endpoint

The URL for the endpoint being documented. It will be copied as is into the final documentation for the endpoint. By convention, any parameters provided in the endpoint url are preceded by colons, like this:

`endpoint: "v1/customers/:id"`

#### http_method

Which HTTP method(s) to use when calling this endpoint. This is a string that will be passed, as-is to the final documentation. For endpoints that accept more than one method, (`PUT` or `PATCH`, for instance), separate them with pipes: `PUT|PATCH`.

#### header

What, if any sort of headers to include in the request to this endpoint. Common choices might be a `Content-Type` header or an `Authentication` header.

#### param

This method defines a param for this endpoint. It is discussed in more detail below.

#### property

Like a `param`, but generally used to define _responses_ rather than requests. Discussed in more detail below.

#### param_group

A param_group is used to, literally, group a set of params or properties together. This may be done for simple organizatonal reasons, but it is most useful for creating sets of parameters that can be reused in multiple endpoint definitions. Param groups are discussed in more detail below.

#### example_request / example_response

There are two ways to provide an example request or an example response for an endpoint. The first is to provide a block to the method itself, adding your example inside:

```ruby
example_request do
  { "param1": "foo", "param2": "bar" }
end
```

The hash will be automatically converted to JSON for presentation purposes.


Alternatively, you can provide a `path` argument that points to a `json` file:

```ruby
  example_request path: "/examples/endpoint_request.json"
```

#### returns

If your API endpoint returns any properties, the `returns` method allows you to specify what they are by identifying them as properties:

```ruby
returns do
  property :response_1, type: "String", desc: "The first part of the response"
  property :response_2, type: "Integer", desc:
end
```

You can also specify a response `code`, whether or not the endpoint returns any other properties. If not specified, the `code` is 200.

```ruby
  returns code: 203 do
    ...
  end
```

### Params and Properties

Describing which parameters your endpoints take and what properties they return is handled by the `param` and `property` methods respectively. These methods work the same way and are technically interchangeable. The only difference is that any defined properties
are considered `required` by default.

Here's an example param:

```ruby
  param :age, type: 'Integer', desc: "How old this person is.", notes: "Used for setting various interface options", validations: "Must be a positive integer.", required: true
```

A param/property takes the following attributes:

#### name

The name of the param/property is the first argument to the method and is always required. Note that it is a positional argument, not a kwarg.

#### type

A kwarg that describes the "type" of the parameter. If you provide a string, this value can be anything you want. It's also possible to pass any valid Ruby type, (String, Array, Hash, etc.), without enclosing it in a string. The `type` argument is required.

#### desc

An optional kwarg that takes a string describing the parameter. For the sake of formatting, it's best if the description is kept relatively short.

#### notes

An optional kwarg for providing additional context or information about a parameter. For the sake of formatting, it's best if the description is kept relatively short. Notes are an optional means of highlighting specific information about a parameter, (such as acceptable values), etc.

#### validations

An optional kwarg for adding a note about any validations present on the given parameter. For the sake of formatting, it's best if the validations argument is kept relatively short.

#### required

Whether or not this parameter is required. Take a boolean and defaults to `false` for a param and `true` for a property.

### Param Groups

Param groups allow you to define a set of parameters that can be shared between individual documentation blocks, reducing duplication. You define them by calling `def_param_group`:

```ruby
  def_param_group :my_group do
    param :param1, type: "Integer", desc: "The first param"
    param :param2, type: "Integer", desc: "The second param"
  end
```
You can define params or properties inside of a param group just like you would inside of an `api_doc` block. To add a param group to a doc block, use the `param_group` method:

```ruby
  api_doc do
    ...

    param_group :my_group

    ...

    returns do
      param_group :my_response_group
    end
  end
```

The `param_group` method takes a single argument, the name of the param group you want to invoke.

Once a param group is defined, it can be used in _any_ documentation block, even those that are in a different source file. For that reason, it may be convenient to define your param groups in files separate from your api documentation itself.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apidoco_dsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apidoco_dsl

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/apidoco_dsl.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
