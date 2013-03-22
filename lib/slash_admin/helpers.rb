module SlashAdmin
  class << self
    def register(model, &block)
      Class.new(Controller) do
        admin model
        instance_exec &block
      end
    end
  
    def each_controller(&block)
      self.constants.each do |name|
        const = self.const_get(name)
        if const.is_a?(Class) && const < Controller
          yield const
        end
      end
    end
  end
end