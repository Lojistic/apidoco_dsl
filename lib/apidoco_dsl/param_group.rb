module ApidocoDsl
  class ParamGroup

    attr_accessor :name, :params

    def initialize(group_name)
      @name = group_name
      @params = []
    end
  end
end
