module SlashAdmin
  class Form
    attr_reader :options, :block

    def initialize(options, block)
      @options = options
      @block = block
    end
  end
end
