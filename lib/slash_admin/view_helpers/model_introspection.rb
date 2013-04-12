SlashAdmin.view_helper(:ModelIntrospection) do
  def model_name(options = {})
    controller.slashadmin_model.model_name.human(options)
  end

  def attribute_name(attribute, options = {})
    controller.slashadmin_model.human_attribute_name(attribute, options)
  end
  
  def slashadmin_default_inputs(include_readonly = false)
    columns = []
      
    controller.slashadmin_model.columns.each do |column|
      next if !include_readonly && (column.primary || column.name == "created_at" || column.name == "updated_at")
      columns << [ :input, column.name ]
    end
      
    drop = Set[]
    associate = {}

    controller.slashadmin_model.reflect_on_all_associations.each do |assoc|
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
end
