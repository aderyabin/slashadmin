module SlashAdmin::Base
  module Tablette
    extend ActiveSupport::Concern
    
    protected
    
    def render_index_partial
      @table = SlashAdmin::Tablette::ArbreTable.new(self, {
        :html_options => {
          :class => "table table-striped table-bordered table-hover"
        }
      }, &self.class.slashadmin_index).to_html(@objects)
    end
  end
end
