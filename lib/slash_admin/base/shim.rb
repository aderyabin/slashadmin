module SlashAdmin::Shim
  def include_into(target, opts = {})
    @include_into = target
    @include_into_options = {
        :if => true
    }.merge(opts)
  end

  def include!
    condition = @include_into_options[:if]
    if condition.respond_to? :call
      condition = condition.call
    end

    if condition
      @include_into.send :include, self
    end
  end
end
