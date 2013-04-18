class SlashAdmin::Components::Panel < Arbre::Component  
  builder_method :panel

  def build(title)
    div title, :class => 'panel-title'
  end
end
