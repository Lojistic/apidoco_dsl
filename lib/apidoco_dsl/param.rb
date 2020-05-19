module ApidocoDsl
  class Param
    attr_accessor :param_key, :param_type, :param_description, :param_notes, :param_required

    def initialize(param_key, param_type, param_required, param_description, param_notes)
      @param_key  = param_key
      @param_type = param_type
      @param_description = param_description
      @param_notes = param_notes
      @param_required = param_required
    end

    def to_h
     param = {}
     param['key'] = param_key unless param_key.nil?
     param['type'] = param_type unless param_type.nil?
     param['description'] = param_description unless param_description.nil?
     param['notes'] = param_notes unless param_notes.nil?
     param['required'] = param_required

     return param
    end

    def key(k)
      self.param_key = k
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

  end
end
