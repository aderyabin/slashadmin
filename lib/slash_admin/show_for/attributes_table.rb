class SlashAdmin::ShowFor::AttributesTable < Arbre::Component
  builder_method :attributes_table

  def build(*args)
    case args.length
    when 0
      record = attributes_table_default_record
      attributes = {}

    when 1
      if args[0].kind_of? Hash
        record = attributes_table_default_record
        attributes = args[0]
      else
        record = args[0]
        attributes = {}
      end
      
    when 2
      record, attributes = *args
      
    else
      raise ArgumentError, "0-2 arguments expected"
    end

    super(attributes)
    
    @builder = ::ShowFor::Builder.new(record, self)
  end
  
  def row(*args, &block)
    @builder.attribute *args, &block
  end
  
  def unite(*args)
    args
  end
  
  def content_tag(tag_name, content, html_options)
    tag = Arbre::HTML::Tag.new(@context)
    tag.instance_exec { @tag_name = tag_name.to_s }
    tag.add_child content
    tag.attributes.merge! html_options
    @arbre_context.current_arbre_element.add_child tag
    tag
  end
  
  def capture(&block)
    nested_context = Arbre::Context.new({}, @arbre_context.helpers)
    nested_context.instance_exec(@builder.object, &block)
    nested_context.to_s
  end
end
