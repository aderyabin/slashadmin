module SlashAdmin
  module ExtensionHelpers
    extend ActiveSupport::Concern
    
    def slashadmin_default_inputs(include_readonly = false)
      columns = []
        
      slashadmin_model.columns.each do |column|
        next if !include_readonly && (column.primary || column.name == "created_at" || column.name == "updated_at")
        columns << [ :input, column.name ]
      end
        
      drop = Set[]
      associate = {}

      slashadmin_model.reflect_on_all_associations.each do |assoc|
        unless include_readonly || assoc.counter_cache_column.nil?
          drop << assoc.counter_cache_column
        end

        if assoc.belongs_to?
          associate[assoc.foreign_key] = assoc.name
        end
      end

      columns.reject! { |name| drop.include? name }
      columns.map! do |name|
        assoc = associate[name[1]]
        if name[0] == :input && !assoc.nil?
          [ :association, assoc ]
        else
          name
        end
      end
      
      columns
    end
    
    def render_index_batch_select(object)
      render_to_string(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object }).html_safe
    end

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end
  end
end
