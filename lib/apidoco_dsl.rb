require "apidoco_dsl/version"
require "apidoco_dsl/documentable"
require 'apidoco_dsl/param'
require "apidoco_dsl/api"
require 'apidoco_dsl/api_doc'
require 'apidoco_dsl/param_group'
require 'apidoco_dsl/railtie'

module ApidocoDsl
  class Error < StandardError; end

  @@api = Api.new

  def self.fetch_docs
    return @@api.api_docs
  end

  def api_doc(&block)
    api_doc = ApiDoc.new(@@api)
    api_doc.instance_exec(&block)

    @@api.api_docs << api_doc
  end

  def def_param_group(group_name, &block)
    param_group = ParamGroup.new(group_name, @@api)
    param_group.instance_exec(&block)

    @@api.param_groups[group_name] = param_group
  end


end
