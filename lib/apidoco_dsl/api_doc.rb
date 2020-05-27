module ApidocoDsl
  class ApiDoc
    include Documentable
    attr_accessor :doc_request_params, :doc_response_params, :doc_published, :doc_name,
                  :doc_endpoint, :doc_http_method, :doc_header, :doc_examples,
                  :doc_sort_order, :doc_description

    #attr_reader :api

    SETTABLE = ['published', 'name', 'endpoint', 'http_method', 'header', 'description', 'sort_order']

    def initialize(api)
      @api                 = api
      @doc_request_params  = []
      @doc_response_params = []
      @doc_examples        = []
      @param_destination   = 'request'
    end

    def param_key
      "Document"
    end

    def returns(&block)
      @param_destination = 'response'
      self.instance_exec(&block)
      @param_destination = 'request'
    end

    def method_missing(name, *args)
      return set_attribute(name, *args) if SETTABLE.include?(name.to_s)
      super
    end

    def set_attribute(name, value)
      self.send(:"doc_#{name}=", value)
    end

    def doc_folder
      self.doc_endpoint.split('/').select{|c| c !~ /^\:/ }[0..-2].join('/')
    end

    def doc_method(*args)
      self.doc_endpoint.split('/').last
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

      return JSON.pretty_generate(doc)
    end

    private

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
