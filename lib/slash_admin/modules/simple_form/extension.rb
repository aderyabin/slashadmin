SlashAdmin.extension(:Base, :SimpleForm) do
  protected
  
  def render_form_partial
    if self.class.slashadmin_form.nil?
      @form = render_to_string(:partial => "/admin/default_form").html_safe
    else
      context = Arbre::Context.new({}, self)
      template = SlashAdmin::SimpleForm::Template.new(self, context)

      SlashAdmin::SimpleForm.apply_config do
        template.simple_form_for @object, {}, &self.class.slashadmin_form
      end

      @form = context.to_s
    end
  end
end
