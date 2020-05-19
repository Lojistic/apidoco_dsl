module ApidocoDsl
  class ApiDoc
    attr_accessor :params, :response_params, :doc_published, :doc_name, :doc_endpoint, :doc_http_method, :doc_header, :doc_examples

    def initialize()
      @params = []
      @response_params = []
      @doc_examples = []
    end

    def doc_folder
      doc_endpoint.split('/').select{|c| c !~ /^\:/ }[0..-2].join('/')
    end

    def doc_method(*args)
      doc_endpoint.split('/').last
    end

    def to_json
      doc = {}
      doc['published'] = doc_published unless doc_published.nil?
      doc['name'] = doc_name unless doc_name.nil?
      doc['end_point'] = doc_endpoint unless doc_endpoint.nil?
      doc['http_method'] = doc_http_method unless doc_http_method.nil?
      doc['params'] = params.map(&:to_h) unless params.empty?
      doc['response_params'] = response_params.map(&:to_h) unless response_params.empty?
      doc['header'] = doc_header unless doc_header.nil?
      doc['examples'] = doc_examples unless doc_examples.empty?

      return JSON.pretty_generate(doc)
    end

  end
end
