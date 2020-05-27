module ApidocoDsl
  class ApiDoc
    include Documentable
    attr_accessor :doc_request_params, :doc_response_params, :doc_published, :doc_name,
                  :doc_endpoint, :doc_http_method, :doc_header, :doc_examples,
                  :doc_sort_order, :doc_description, :doc_request_example, :doc_response_example,
                  :doc_return_code, :doc_namespace, :doc_resource

    #attr_reader :api

    SETTABLE = ['published', 'name', 'endpoint',
                'http_method', 'header', 'description', 'sort_order']

    def initialize(api)
      @api                 = api
      @doc_request_params  = []
      @doc_response_params = []
      @doc_examples        = []
      @doc_namespace       = @api.namespace
      @doc_resource        = @api.resource
      @param_destination   = 'request'
    end

    def param_key
      "Document"
    end

    def returns(code: 200, &block)
      @doc_return_code = translate_return_code(code)
      @param_destination = 'response'
      self.instance_exec(&block) if block_given?
      @param_destination = 'request'
    end

    def method_missing(name, *args)
      return set_attribute(name, *args) if SETTABLE.include?(name.to_s)
      super
    end

    def set_attribute(name, value)
      self.send(:"doc_#{name}=", value)
    end

    def example_request(path: nil)
      ex = {}
      ex['request'] = yield if block_given?
      ex['request'] = JSON.parse(File.read(path)) if path
      @doc_examples << ex
    end

    def example_response(path: nil)
      ex = {}
      ex['response'] = yield if block_given?
      ex['response'] = JSON.parse(File.read(path)) if path
      @doc_examples << ex
    end

    def doc_folder
      doc_namespace.split('::').map(&:underscore).map(&:downcase).join('/') + "/#{doc_resource.to_s.underscore}/"
    end

    def doc_file
      doc_name.gsub(/\s/, '').underscore
    end

    def to_json
      doc = {}
      doc['published']       = doc_published unless doc_published.nil?
      doc['name']            = doc_name unless doc_name.nil?
      doc['end_point']       = doc_endpoint unless doc_endpoint.nil?
      doc['http_method']     = doc_http_method unless doc_http_method.nil?
      doc['params']          = unroll_parameters(doc_request_params, [])  unless doc_request_params.empty?
      doc['response_params'] = unroll_parameters(doc_response_params, []) unless doc_response_params.empty?
      doc['header']          = doc_header unless doc_header.nil?
      doc['description']     = doc_description unless doc_description.nil?
      doc['examples']        = doc_examples unless doc_examples.empty?
      doc['sort_order']      = doc_sort_order unless doc_sort_order.nil?
      doc['return_code']     = doc_return_code

      return JSON.pretty_generate(doc)
    end

    private

    def translate_return_code(code)
      trans = {
        100 => :continue,
        101 => :switching_protocols,
        102 => :processing,
        200 => :ok,
        201 => :created,
        202 => :accepted,
        203 => :non_authoritative_information,
        204 => :no_content,
        205 => :reset_content,
        206 => :partial_content,
        207 => :multi_status,
        226 => :im_used,
        300 => :multiple_choices,
        301 => :moved_permanently,
        302 => :found,
        303 => :see_other,
        304 => :not_modified,
        305 => :use_proxy,
        307 => :temporary_redirect,
        400 => :bad_request,
        401 => :unauthorized,
        402 => :payment_required,
        403 => :forbidden,
        404 => :not_found,
        405 => :method_not_allowed,
        406 => :not_acceptable,
        407 => :proxy_authentication_required,
        408 => :request_timeout,
        409 => :conflict,
        410 => :gone,
        411 => :length_required,
        412 => :precondition_failed,
        413 => :request_entity_too_large,
        414 => :request_uri_too_long,
        415 => :unsupported_media_type,
        416 => :requested_range_not_satisfiable,
        417 => :expectation_failed,
        422 => :unprocessable_entity,
        423 => :locked,
        424 => :failed_dependency,
        426 => :upgrade_required,
        500 => :internal_server_error,
        501 => :not_implemented,
        502 => :bad_gateway,
        503 => :service_unavailable,
        504 => :gateway_timeout,
        505 => :http_version_not_supported,
        507 => :insufficient_storage,
        510 => :not_extended
      }.invert

      trans[code] || code
    end

    def unroll_parameters(params, unrolled = [])
      # Unrolling parameters is a matter of recursively seeking down through each base set of params for
      # each of _their_ params, and assigning/setting keys appropriately.

      params.each do |pr|
        if pr.params.any?

          unrolled << pr.to_h
          duped = pr.params.dup
          duped.each{|d| d.parent = pr; }
          unroll_parameters(duped, unrolled)
        else
          unrolled << pr.to_h
        end

      end

      return unrolled
    end

    def push_to
      self.send(:"doc_#{@param_destination}_params")
    end

  end
end
