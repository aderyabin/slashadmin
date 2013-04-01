module SlashAdmin
  module ExtensionHelpers
    extend ActiveSupport::Concern
    
    def slashadmin_form_columns
      column_names = Set[]
        
      slashadmin_model.columns.each do |column|
        next if column.primary || column.name == "created_at" || column.name == "updated_at"
        column_names.add column.name
      end
        
      slashadmin_model.reflect_on_all_associations.each do |assoc|
        column_names.delete assoc.counter_cache_column
        if assoc.belongs_to?
          column_names.delete assoc.foreign_key
        end
      end
      
      column_names
    end
    
    def slashadmin_index_columns
      column_names = Set[]
        
      slashadmin_model.columns.each do |column|
        column_names.add column.name
      end
      
      column_names
    end
    
    def render_index_batch_select(object)
      render_to_string(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object }).html_safe
    end

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end
  end
end
