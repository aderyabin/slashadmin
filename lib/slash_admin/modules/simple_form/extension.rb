SlashAdmin.extension(:Base, :SimpleForm) do
  protected
  
  def render_form_partial
    if slashadmin_form.nil?
      @form = render_to_string(:partial => "/admin/default_form").html_safe
    else
      context = Arbre::Context.new({}, self)
      template = SlashAdmin::SimpleForm::Template.new(self, context)

      SlashAdmin::SimpleForm.apply_config do
        template.simple_form_for @object, slashadmin_form_options || {}, &slashadmin_form
      end

      @form = context.to_s
    end
  end
end
