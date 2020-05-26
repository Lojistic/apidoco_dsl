module ApidocoDsl
  module Documentable
    attr_accessor :api

    def param(key, type:, desc: nil, notes: nil, validations: nil, required: false, &block)
      this_param = Param.new(
        param_key: key,
        param_type: type,
        param_description: desc,
        param_notes: notes,
        param_required: required,
        param_validations: validations,
        parent: self
      )

      if block_given?
        this_param.instance_exec(this_param, &block)
      end

      push_to << this_param
    end

    # There may be a clever way to do this, preserving key ancestry without duplication...I haven't found it.
    def property(key, type:, desc: nil, notes: nil, validations: nil, required: true, &block)
      this_param = Param.new(
        param_key: key,
        param_type: type,
        param_description: desc,
        param_notes: notes,
        param_required: required,
        param_validations: validations,
        parent: self
      )

      if block_given?
        this_param.instance_exec(this_param, &block)
      end

      push_to << this_param
    end

    #alias property param

    def param_group(group_name)
      @api.param_groups[group_name].params.each{|param| push_to << param }
    end

  end
end

