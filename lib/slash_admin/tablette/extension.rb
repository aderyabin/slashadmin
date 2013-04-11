module SlashAdmin::Base
  module Tablette
    extend ActiveSupport::Concern
    
    protected
    
    def render_index_partial
      if self.class.slashadmin_index.nil?
        @table = render_to_string :partial => "/admin/index/default_index"
      else
        @table = SlashAdmin::Tablette::ArbreTable.new(self, {
          :html_options => {
            :class => "table table-striped table-bordered table-hover"
          }
        }, &self.class.slashadmin_index).to_html(@objects)
      end
    end
  end
end
