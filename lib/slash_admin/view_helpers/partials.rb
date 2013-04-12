SlashAdmin.view_helper(:Partials) do 
  def render_index_batch_select(object)
    render(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object })
  end

  def render_default_index_actions(object)
    render(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object })
  end
end