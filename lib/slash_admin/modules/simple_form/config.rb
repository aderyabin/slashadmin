module SlashAdmin::SimpleForm
  def self.simple_form_config
    {
      :default_wrapper        => :slashadmin_bootstrap,
      :boolean_style          => :inline,
      :button_class           => 'btn',
      :error_notification_tag => :div,
      :label_class            => 'control-label',
      :form_class             => 'simple_form form-horizontal',
      :control_wrapper_class  => 'form-actions'
    }
  end

  def self.apply_config(*args, &block)
    config = self.simple_form_config
    prev = {}
    
    begin
      config.each do |key, value|
        prev[key] = ::SimpleForm.send key
        ::SimpleForm.send "#{key}=", value
      end

      block.call(*args)

    ensure
      prev.each do |key, value|
        ::SimpleForm.send "#{key}=", value
      end
    end
  end
end
