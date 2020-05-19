module ApidocoDsl
  class Param
    attr_accessor :bare_param_key, :param_key, :param_type, :param_description,
                  :param_notes, :param_required, :param_validations,
                  :parent_keys

    def initialize(param_key, param_type, param_required, param_description, param_notes, param_validations)
      @param_key       = param_key
      @bare_param_key  = param_key
      @param_type = param_type
      @param_description = param_description
      @param_notes = param_notes
      @param_validations = param_validations
      @param_required = param_required
      @parent_keys = []
    end

    def to_h
     param = {}
     param['key'] = param_key unless param_key.nil?
     param['type'] = param_type unless param_type.nil?
     param['description'] = param_description unless param_description.nil?
     param['notes'] = param_notes unless param_notes.nil?
     param['required'] = param_required
     param['validations'] = param_validations unless param_validations.nil?

     return param
    end

    def key(k)
      self.bare_param_key = k
      self.param_key = derive_key(k)
    end

    def param_key
      derive_key(self.bare_param_key)
    end

    def type(t)
      self.param_type = t
    end

    def description(d)
      self.param_description = d
    end

    def notes(n)
      self.param_notes = n
    end

    def required(r)
      self.param_required = r
    end

    def validations(v)
      self.param_validations = v
    end

    private

    def derive_key(k)
      if @parent_keys.any?
        base = "#{@parent_keys[0]}"

        parent_keys[1..-1].each do |key|
          base << "[#{key}]"
        end

        base << "[#{k}]"
      else
        k
      end
    end

  end
end
