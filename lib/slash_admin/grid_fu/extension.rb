module SlashAdmin::Base
  module GridFu
    extend ActiveSupport::Concern
    
    protected
    
    def render_index_partial
      @table = SlashAdmin::GridFu::ArbreTable.new(self, &self.class.slashadmin_index).to_html(self.fetch_index)
    end
  end
end
