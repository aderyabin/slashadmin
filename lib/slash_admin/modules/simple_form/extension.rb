SlashAdmin.extension(:Base, :SimpleForm) do
  protected
  
  def render_form_partial
    if slashadmin_form.nil?
      @form = render_to_string(:partial => "/admin/default_form").html_safe
    else
      form = nil
      view_context.instance_exec do
        context = Arbre::Context.new({}, self)
        template = SlashAdmin::SimpleForm::Template.new(self, context)

        SlashAdmin::SimpleForm.apply_config do
          template.simple_form_for @object, controller.slashadmin_form.options || {}, &controller.slashadmin_form.block
        end

        form = context.to_s
      end

      @form = form
    end
  end
end
