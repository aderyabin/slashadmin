module Arbre::Element::BuilderMethods
  def attributes_table(*args, &block)
    klass = SlashAdmin::ShowFor::AttributesTable
  
    SlashAdmin::ShowFor.apply_config do
      insert_tag klass, *args, &block
    end
  end
end

class SlashAdmin::ShowFor::AttributesTable < Arbre::Component  
  def build(record, attributes = {})
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
