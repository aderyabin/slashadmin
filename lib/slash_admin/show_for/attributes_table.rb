module Arbre::Element::BuilderMethods
  def attributes_table(*args, &block)
    klass = SlashAdmin::ShowFor::AttributesTable
  
    config = klass.show_for_config
    restore = {}
    begin
      config.each do |key, value|
        restore[key] = ShowFor.send(key)
        ShowFor.send("#{key}=", value)
      end
  
      insert_tag klass, *args, &block
    ensure
      restore.each do |key, value|
        ShowFor.send("#{key}=", value)
      end
    end
  end
end

class SlashAdmin::ShowFor::AttributesTable < Arbre::Component
  def self.show_for_config
    {
      "show_for_tag"        => 'div',
      "label_tag"           => 'div',
      "label_class"         => 'show-for-label',
      "separator"           => '',
      "content_tag"         => 'div',
      "content_class"       => 'show-for-content',
      "blank_content_class" => 'show-for-content-blank',
      "wrapper_tag"         => 'div',
      "wrapper_class"       => 'show-for-wrapper'
    }
  end
  
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
