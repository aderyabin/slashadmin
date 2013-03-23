module SlashAdmin::SimpleForm
  class Template
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::ControllerHelper
    include ActionView::RecordIdentifier
    include SimpleForm::ActionViewExtensions::FormHelper
    
    attr_reader :controller
    delegate :polymorphic_path, :to => :controller
  
    attr_accessor :output_buffer
    
    def initialize(controller, context)
      @controller = controller
      @context = context
    end
    
    def unite(*args)
      args
    end

    def capture(*args, &block)
      old_context = @context
      children = begin
        @context = Arbre::Context.new({}, @context.helpers)
        @context.instance_exec(*args, &block)
        @context.children
      ensure
        @context = old_context
      end
      
      children.each do |child|
        child.instance_variable_set :@arbre_context, @context
        child.parent = nil
      end
      
      children
    end
    
    def protect_against_forgery?
      @controller.send :protect_against_forgery?
    end
    
    def form_authenticity_token
      @controller.send :form_authenticity_token
    end
    
    def form_tag_in_block(html_options, &block)
      authenticity_token = html_options.delete("authenticity_token")
      method = html_options.delete("method").to_s

      tag = Arbre::HTML::Tag.new(@context)
      tag.instance_variable_set :@tag_name, "form"
      @context.current_arbre_element.add_child tag

      container = Arbre::HTML::Tag.new(@context)
      container.instance_variable_set :@tag_name, "div"
      container.attributes["style"] = "margin:0;padding:0;display:inline";
      tag.add_child container

      case method
      when /^get$/i # must be case-insensitive, but can't use downcase as might be nil
        html_options["method"] = "get"
        
      when /^post$/i, "", nil
        html_options["method"] = "post"
        container.add_child(token_tag(authenticity_token))
      else
        html_options["method"] = "post"
        container.add_child(method_tag(method))
        container.add_child(token_tag(authenticity_token))
      end

      container.add_child(utf8_enforcer_tag)

      content = block.call

      tag.attributes.merge! html_options
      tag.add_child(content)
      
      [ tag ]
    end
    
    def tag(name, attributes)
      tag = Arbre::HTML::Tag.new(@context)
      tag.instance_variable_set :@tag_name, name
      tag.attributes.merge! make_attributes(attributes)
      @context.current_arbre_element.add_child tag
      
      [ tag ]
    end
    
    def content_tag_string(name, content, options, escape = true)
      tag = Arbre::HTML::Tag.new(@context)
      tag.instance_variable_set :@tag_name, name
      tag.attributes.merge! make_attributes(options)
      
      tag.add_child(content)
      @context.current_arbre_element.add_child tag
      
      [ tag ]
    end
    
    private
    
    def stringify_attribute_value(value)
      case value
      when String
        value
        
      when Array
        value.map(&method(:stringify_attribute_value)).join(" ")
      
      else
        raise ArgumentError, "unexpected #{value.inspect} in attributes"
      end
    end
    
    def make_attributes(attributes)
      out = {}
      
      attributes.each do |key, value|
        content = stringify_attribute_value value
        key = key.to_s
        existing = out[key]
        if existing.nil?
          out[key] = content
        else
          out[key] = "#{existing} #{content}"
        end
      end
      
      out
    end
  end
end
