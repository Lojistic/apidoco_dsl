module ApidocoDsl
  class ParamGroup
    include Documentable

    attr_accessor :name, :params

    def initialize(group_name, api)
      @name   = group_name
      @api    = api
      @params = []
      @doc_request_params = @params
    end

    def doc_request_params
      @params
    end
    alias doc_response_params doc_request_params

    private

    def push_to
      @params
    end

  end
end
