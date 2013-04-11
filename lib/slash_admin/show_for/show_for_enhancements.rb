class ShowFor::Builder
  def wrap_label_and_content(name, value, options, &block)
    children = [ ]
    
    label_text = label(name, options, false)
    if label_text.present?
      children << label_text
      children << ShowFor.separator.to_s.html_safe
    end
    
    children << content(value, options, false, &block)
    
    wrap_with(:wrapper, unite(*children), options)
  end
  
  private
  
  def unite(*args)
    if @template.respond_to? :unite
      @template.unite *args
    else
      buf = ""
      args.each &buf.method(:concat)

      buf.html_safe
    end
  end
end
