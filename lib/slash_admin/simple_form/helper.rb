module SlashAdmin::ApplicationHelper
  def slashadmin_simple_form_for(record, options = {}, &block)
    SlashAdmin::SimpleForm.apply_config do
      simple_form_for record, options, &block
    end
 end
end