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

    def param_group(group_name)
      # Param groups seem to have trouble inheriting parentage correctly.
      # This appears to be because the params are "parented" when they are
      # initally defined and when grabbing them here, we need to "re-parent"
      # them...or more accurately, a copy of them.
      #
      # Again, problem, because a single param may itself have multiple layers
      # of child params and groups...
      #
      # An interesting note here is that defining a nested grouping _manually_
      # appears to have the desired effect.

      pg = @api.param_groups[group_name].deep_dup
      #pg.reparent(self) # Make the calling object the top-level parent for every param in this group

      return false unless pg # FIXME This seems more like an autoloading issue than anything?
      pg.params.each do |param|
        push_to << param
      end

    end

  end
end

