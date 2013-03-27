module SlashAdmin::Base
  module GridFu
    extend ActiveSupport::Concern
    
    protected
    
    def render_index_partial
      @table = SlashAdmin::GridFu::ArbreTable.new(self, {
        :html_options => {
          :class => "table table-striped table-bordered table-hover"
        }
      }, &self.class.slashadmin_index).to_html(@objects)
    end
  end
end
