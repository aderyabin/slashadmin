SlashAdmin.view_helper(:Partials) do 
  def render_selectable_column(object)
    render(:layout => false, :partial => "admin/index/selectable_column", :locals => { :object => object })
  end

  def render_default_index_actions(object)
    render(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object })
  end
end