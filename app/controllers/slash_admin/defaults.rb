module SlashAdmin
  module Defaults
    extend ActiveSupport::Concern
   
    included do
      Controller.slashadmin_default_index = ->() do
        columns = slashadmin_default_inputs(true)

        header! do
          column I18n.t('admin.index.batch_select_column')

          columns.each do |(type, name)|
            column slashadmin_model.human_attribute_name(name)
          end

          column I18n.t('admin.index.actions_column')
        end

        batch_select

        columns.each do |type, name|
          case type
          when :association
            column name do |record|
              target = record.send name

              link_text = I18n.t('admin.index.association_link', :model => target.class.model_name.human, :id => target.id)
              begin 
                a(:href => url_for(:controller => "admin_#{name}", :action => "show", :id => target.id)) do
                  link_text
                end
              rescue ActionController::UrlGenerationError
                link_text
              end
            end

          else
            column name 
          end
        end

        default_actions
      end
      
      Controller.slashadmin_default_show = ->(record) do
        attributes_table do
          slashadmin_default_inputs(true).each do |type, name|
            case type
            when :association
              row(name.to_sym) do 
                target = record.send name

                link_text = I18n.t('admin.show.association_link', :model => target.class.model_name.human, :id => target.id)
                begin 
                  a(:href => url_for(:controller => "admin_#{name}", :action => "show", :id => target.id)) do
                    link_text
                  end
                rescue ActionController::UrlGenerationError
                  link_text
                end
              end
            else
              row name.to_sym
            end
          end
        end
      end
    end
  end
end