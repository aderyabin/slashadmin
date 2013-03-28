module SlashAdmin::Base
  module SimpleForm
    extend ActiveSupport::Concern

    def render_form_partial
      context = Arbre::Context.new({}, self)
      template = SlashAdmin::SimpleForm::Template.new(self, context)

      config = {
        :default_wrapper        => :slashadmin_bootstrap,
        :boolean_style          => :nested,
        :button_class           => 'btn',
        :error_notification_tag => :div,
        :label_class            => 'control-label',
        :form_class             => 'simple_form form-horizontal',
        :control_wrapper_class  => 'form-actions'
      }
      
      prev = {}
      
      begin
        config.each do |key, value|
          prev[key] = ::SimpleForm.send key
          ::SimpleForm.send "#{key}=", value
        end

        template.simple_form_for @object, {}, &self.class.slashadmin_form
      ensure
        prev.each do |key, value|
          ::SimpleForm.send "#{key}=", value
        end
      end
      
      @form = context.to_s
    end
  end
end
