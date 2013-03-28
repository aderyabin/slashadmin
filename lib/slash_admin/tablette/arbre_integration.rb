module SlashAdmin::Tablette
  class ArbreRenderer
    attr_reader :context
    attr_accessor :element
    
    def initialize(controller)
      @context = Arbre::Context.new
    end
    
    def produce_element(tag, attributes, content)
      element = Arbre::HTML::Tag.new(@context)
      element.instance_exec { @tag_name = tag }
      element.attributes.merge! flatten_attributes(attributes)
      element.add_child(content)
      
      element
    end
    
    def to_html(root)
      root.to_s
    end
    
    def wrap_content(p)
      ->(*args) do
        arbre_context = Arbre::Context.new({}, element)
        plain = arbre_context.instance_exec(*args, &p)
        
        if arbre_context.children.any?
          arbre_context.children.to_a
        else
          plain
        end
      end
    end
    
    private
    
    def flatten_attributes(attributes, prefix = "")
      ret = {}
      
      attributes.each do |key, value|
        if value.kind_of? Hash
          ret.merge! flatten_attributes(value, "#{key}-")
        else
          ret[key] = value
        end
      end
      
      ret
    end
  end
  
  class ArbreTable < ::Tablette::Table
    def initialize(controller, options = {}, &body)
      renderer = ArbreRenderer.new(controller)
      
      super(
        {
          :renderer => renderer,
          :helper   => controller,
        }.merge(options),
        &body
      )
    end
  end
end
