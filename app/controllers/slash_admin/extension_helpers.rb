module SlashAdmin
  module ExtensionHelpers
    extend ActiveSupport::Concern
    
    def render_index_batch_select(object)
      render_to_string(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object }).html_safe
    end

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end
    
    protected
  
    def fetch_index
      slashadmin_model.all
    end
  
    def fetch_show
      slashadmin_model.find(params[:id])
    end
  end
end

