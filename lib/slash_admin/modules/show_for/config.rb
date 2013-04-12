module SlashAdmin::ShowFor
  def self.show_for_config
    {
      "show_for_tag"        => 'div',
      "label_tag"           => 'div',
      "label_class"         => 'show-for-label',
      "separator"           => '',
      "content_tag"         => 'div',
      "content_class"       => 'show-for-content',
      "blank_content_class" => 'show-for-content-blank',
      "wrapper_tag"         => 'div',
      "wrapper_class"       => 'show-for-wrapper'
    }
  end

  def self.apply_config(*args, &block)
    config = self.show_for_config
    restore = {}
    begin
      config.each do |key, value|
        restore[key] = ShowFor.send(key)
        ShowFor.send("#{key}=", value)
      end
  
      block.call(*args)
    ensure
      restore.each do |key, value|
        ShowFor.send("#{key}=", value)
      end
    end
  end
end
