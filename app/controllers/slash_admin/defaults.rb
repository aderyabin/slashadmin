module SlashAdmin
  module Defaults
    extend ActiveSupport::Concern
   
    included do
      Controller.slashadmin_default_index = ->() do
        columns = slashadmin_index_columns

        header! do
          column ''

          columns.each do |name|
            column slashadmin_model.human_attribute_name(name)
          end

          column 'Actions'
        end

        batch_select
        
        columns.each do |name|
          column name
        end

        default_actions
      end
      
      Controller.slashadmin_default_show = ->(object) do
        attributes_table do
          slashadmin_index_columns.each do |column|
            row column.to_sym
          end
        end
      end
    end
  end
end