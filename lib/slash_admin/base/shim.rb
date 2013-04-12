module SlashAdmin::Shim
  def include_into(target)
    @include_into = target
  end

  def include!
    @include_into.send :include, self
  end
end
