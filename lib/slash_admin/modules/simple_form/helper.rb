SlashAdmin.view_helper(:SimpleForm) do
  def slashadmin_simple_form_for(record, options = {}, &block)
    SlashAdmin::SimpleForm.apply_config do
      simple_form_for record, options, &block
    end
  end

  def slashadmin_simple_form_for_arbre(record, options = {}, &block)
    context = Arbre::Context.new({}, self)
    template = SlashAdmin::SimpleForm::Template.new(self, context)

    SlashAdmin::SimpleForm.apply_config do
      template.simple_form_for record, options, &block
    end

    context.to_s
  end
end
