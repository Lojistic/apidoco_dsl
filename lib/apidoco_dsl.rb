require "apidoco_dsl/version"
require 'apidoco_dsl/api_doc'
require 'apidoco_dsl/param_group'
require 'apidoco_dsl/param'
require 'apidoco_dsl/railtie'

module ApidocoDsl
  class Error < StandardError; end

  @@api_docs = []
  @@param_groups = {}

  def self.fetch_docs()
    raise "No documentation defined" unless defined?(@@api_docs)
    return @@api_docs
  end

  def api_doc(&block)
    @doc          = ApiDoc.new
    yield
    @@api_docs << @doc
  end

  def def_param_group(group_name, &block)
    @pg = ParamGroup.new(group_name)
    yield
    @@param_groups[group_name] = @pg
    @pg = nil
  end

  def published(p)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_published = p
  end

  def name(n)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_name = n
  end

  def endpoint(e)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_endpoint = e
  end

  def http_method(h)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_http_method = h
  end

  def header(h)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_header = h
  end

  def sort_order(s)
    raise "Must be inside a doc block" unless @doc
    @doc.doc_sort_order = s
  end

  def params(group: nil, array_of: nil, &block)
    raise "must be inside a doc block"  unless @doc

    @params = []
    @params = fetch_param_group(group) if group || array_of

    yield if block_given?

    @doc.params = @params
    @params = nil
  end

  def response_params(group: nil, array_of: nil, &block)
    raise "must be inside a doc block"  unless @doc

    @response_params = []
    @response_params = fetch_param_group(group) if group || array_of

    yield if block_given?

    @doc.response_params = @response_params
    @response_params = nil
  end

  def param(key: nil, type: nil, required: false, description: '', notes: '', validations: '', &block)
    raise "must be inside a params block"  unless @params || @response_params || @pg

    @depth_stack ||= []
    @param = Param.new(key, type, required, description, notes, validations)

    if %w(hash array).include?(type.downcase)
      @depth_stack << @param.param_key
      return resolve_hash_param(block)
    else
      @param.parent_keys = @depth_stack.dup
    end

    if block_given?
      yield @param
    end

    if @pg
      @pg.params << @param
    else
      push_to = @params || @response_params
      push_to << @param
    end
  end

  def resolve_hash_param(block)
    block.call
    @depth_stack.pop if @depth_stack.any?
  end

  def example_request(path: nil, &block)
    raise "Must be inside a doc block" unless @doc
    ex = {}
    ex['request'] = yield if block_given?
    ex['request'] = JSON.parse(File.read(path)) if path
    @doc.doc_examples << ex
  end

  def example_response(path: nil, &block)
    raise "Must be inside a doc block" unless @doc
    ex = {}
    ex['response'] = yield if block_given?
    ex['response'] = JSON.parse(File.read(path)) if path
    @doc.doc_examples << ex
  end


  private

  def fetch_param_group(group)
    p '&&&&&&&&&&'
    p '&&&&&&&&&&'
    p '&&&&&&&&&&'
    p group
    return @@param_groups[group].params
  end

end
