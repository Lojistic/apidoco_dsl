require "apidoco_dsl/version"
require 'apidoco_dsl/api_doc'
require 'apidoco_dsl/param'
require 'apidoco_dsl/param_group'
require 'apidoco_dsl/example'
require 'apidoco_dsl/railtie'

module ApidocoDsl
  class Error < StandardError; end

  def self.fetch_docs()
    raise "No documentation defined" unless defined?(@@api_docs)
    return @@api_docs
  end

  def api_doc(&block)
    @@doc    = ApiDoc.new
    @@params = []
    @@hash_params = ''

    @@api_docs ||= []
    doc   = ApiDoc.new
    @@doc = doc
    yield

    @@api_docs << doc
    @@doc = nil
  end

  def def_param_group(group_name, &block)
    @@param_groups ||= {}
    @@params ||= []
    @@hash_params = ''

    @@pg = ParamGroup.new(group_name)
    yield
    @@param_groups[group_name] = @@pg
  end





  def published(p)
    raise "Must be inside a doc block" unless @@doc
    @@doc.doc_published = p
  end

  def name(n)
    raise "Must be inside a doc block" unless @@doc
    @@doc.doc_name = n
  end

  def endpoint(e)
    raise "Must be inside a doc block" unless @@doc
    @@doc.doc_endpoint = e
  end

  def http_method(h)
    raise "Must be inside a doc block" unless @@doc
    @@doc.doc_http_method = h
  end

  def header(h)
    raise "Must be inside a doc block" unless @@doc
    @@doc.doc_header = h
  end

  def example_request(path: nil, &block)
    raise "Must be inside a doc block" unless @@doc
    ex = {}
    ex['request'] = yield if block_given?
    ex['request'] = JSON.parse(File.read(path)) if path
    @@doc.doc_examples << ex
  end

  def example_response(path: nil, &block)
    raise "Must be inside a doc block" unless @@doc
    ex = {}
    ex['response'] = yield if block_given?
    ex['response'] = JSON.parse(File.read(path)) if path
    @@doc.doc_examples << ex
  end

  def params(group: nil, &block)
    raise "must be inside a doc block or a param group"  unless @@doc || @@pg
    @@params = []

    @@params = fetch_param_group(group) if group

    yield if block_given?

    @@doc.params = @@params
    @@params = nil
  end

  def response_params(group: nil, &block)
    raise "must be inside a doc block"  unless @@doc
    @@params ||= []

    @@params = fetch_param_group(group) if group

    yield if block_given?

    @@doc.response_params = @@params
    @@params = nil
  end

  def param(key: nil, type: nil, required: false, description: '', notes: '', &block)
    raise "must be inside a params block"  unless @@params
    return hash_param(key, type, required, description, notes, block) if type.to_s.downcase == 'hash'
    param = Param.new(key, type, required, description, notes)

    if block_given?
      yield param
    end

    if @@hash_params
      param.param_key = "#{@@hash_params}[#{key}]"
    end

    if defined?(@@pg) && @@pg
      @@pg.params << param
    else
      @@params << param
    end

    return param
  end

  def hash_param(key, type, required, description, notes, block)
    base_param = Param.new(key, type, required, description, notes)
    @@params << base_param

    @@hash_params ||= key
    block.yield
    @@hash_params = nil
  end

  private

  def fetch_param_group(group)
    return @@param_groups[group].params
  end

end
