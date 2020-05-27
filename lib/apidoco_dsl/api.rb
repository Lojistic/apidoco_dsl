module ApidocoDsl
  class Api
    attr_accessor :api_docs, :param_groups, :namespace, :resource

    def initialize
      @api_docs = []
      @param_groups = {}
    end
  end
end
