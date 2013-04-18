class SlashAdmin::Components::StatusTag < Arbre::Component  
  builder_method :status_tag

  def tag_name
    'span'
  end

  def default_class_name
    'label'
  end

  def build(text, status)
    case status.to_s
    when 'ok'
      add_class 'label-success'

    when 'error'   
      add_class 'label-important'

    when 'warning'
      add_class 'label-warning'

    when 'raw'
    end
    
    text
  end
end
