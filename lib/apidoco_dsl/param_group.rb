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


    def reparent(new_parent)
      original_params = @params.deep_dup
      @params = []

      p '&&&&&&&&&&'
      p '&&&&&&&&&&'
      p '&&&&&&&&&&'
      #original_params.each do |param|
        #p param.parent.class
        #p param.display_key #unless param.parent
      #end

      #original_params.each do |param|
        #param = param.dup
        #param.parent = new_parent

        #@params << param
      #end

      @params.each do |param|
        p param.parent.parent.class
        p param.parent.display_key
        p param.display_key #unless param.parent
      end
    end

    private

    def push_to
      @params
    end

  end
end
