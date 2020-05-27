module ApidocoDsl
  class Param
    include Documentable

      attr_accessor :param_key, :param_type, :param_description,
                  :param_notes, :param_validations, :param_required, :params, :parent

    SETTABLE = ['key', 'type', 'description', 'notes', 'validations', 'required']

    def initialize(param_key:,
                   param_type:,
                   param_description: nil,
                   param_notes: nil,
                   param_validations: nil,
                   param_required: false,
                   parent: nil)

      @param_key         = param_key
      @param_type        = param_type
      @param_description = param_description
      @param_notes       = param_notes
      @param_validations = param_validations
      @param_required    = param_required
      @parent            = parent
      @params            = []
      @api               = parent.api
    end

    def method_missing(name, *args)
      return set_attribute(name, *args) if SETTABLE.include?(name.to_s)
      super
    end

    def set_attribute(name, value)
      self.send(:"param_#{name}=", value)
    end

    def doc_request_params
      @params
    end
    alias doc_response_params doc_request_params

    def to_h
      param = {}
      param['key'] =  compound_key
      param['type'] = param_type unless param_type.nil?
      param['description'] = param_description unless param_description.nil?
      param['notes'] = param_notes unless param_notes.nil?
      param['required'] = param_required
      param['validations'] = param_validations unless param_validations.nil?

      return param
    end

    def display_key
      return param_key.to_s unless @parent && @parent.is_a?(Param)
      return "[#{param_key.to_s}]"
    end

    private

    def compound_key
      return param_key.to_s unless @parent && @parent.is_a?(Param)

      ancestors = []
      this_parent = @parent
      ancestor    = this_parent

      while ancestor
        ancestors << ancestor
        ancestor = ancestor.try(:parent)
      end

      keys = ancestors.map{|a| a.try(:display_key) }.reverse

      compounded = keys.map(&:to_s).join('')
      return compounded + display_key
    end

    def push_to
      @params
    end

  end
end
