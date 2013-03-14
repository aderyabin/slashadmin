module SlashAdmin
  def self.register(model, &block)
    Class.new(SlashAdmin::Controller) do
      admin model
      instance_exec &block
    end
  end
end
