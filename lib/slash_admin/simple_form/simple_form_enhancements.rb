class SimpleForm::Wrappers::Many
  def render(input)
    list = []
    options = input.options
    
    components.each do |component|
      next if options[component] == false
      if component.respond_to? :render
        rendered = component.render(input)
      else
        rendered = input.send(component)
      end
      
      list << rendered if rendered
    end
    
    if input.template.respond_to? :unite
      content = input.template.unite(list)
    else
      content = "".html_safe
      list.each { |item| content.safe_concat item.to_s }
    end
    
    wrap(input, options, content)
  end
end
