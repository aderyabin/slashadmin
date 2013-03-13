module SlashAdmin
  def self.register(model, &block)
    Class.new(SlashAdmin::Controller) do
      admin model
      yield
    end
  end
end
