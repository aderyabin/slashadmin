module SlashAdmin::Base
  module SimpleForm
    extend ActiveSupport::Concern

    def render_form_partial
      context = Arbre::Context.new({}, self)
      template = SlashAdmin::SimpleForm::Template.new(self, context)

      template.form_for @object, {
        :builder => ::SimpleForm::FormBuilder
      }, &self.class.slashadmin_form
      
      @form = context.to_s
    end
  end
end
