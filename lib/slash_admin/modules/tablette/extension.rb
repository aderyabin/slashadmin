SlashAdmin.extension(:Base, :Tablette) do
  protected
  
  def render_index_partial
    if self.class.slashadmin_index.nil?
      @table = render_to_string :partial => "/admin/index/default_index"
    else
      table = nil
      view_context.instance_exec do
        table = SlashAdmin::Tablette::ArbreTable.new(self, {
          :html_options => {
            :class => "table table-striped table-bordered table-hover"
          }
        }, &controller.slashadmin_index).to_html(@objects)
      end
      @table = table
    end
  end
end
