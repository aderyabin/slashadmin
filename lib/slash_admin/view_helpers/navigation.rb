SlashAdmin.view_helper(:Navigation) do
  class BreadcrumbBuilder
    attr_reader :list

    def initialize
      @list = {}
    end

    def trail(name, path)
      @list[name] = path
    end
  end
    
  def generate_menu
    root = {
      :label => "root",
      :children => [],
      :priority => 0,
      :parent => nil,
      :id => 0
    }
    
    index = 1
    
    SlashAdmin.each_controller do |controller|
      menu_options = controller.new.slashadmin_layout.menu_options

      next if menu_options[:hidden] || (menu_options.include?(:if) && !self.controller.instance_exec(&menu_options[:if]))
      
      label = menu_options.fetch(:label, controller.slashadmin_model.model_name.human(:count => 3))
      parent = menu_options.fetch(:parent, "root")
      
      parent_node = search_in_tree(root) { |n| n[:label] == parent }
      if parent_node.nil?
        parent_node = {
          :label => parent,
          :children => [],
          :priority => 10,
          :parent => root,
          :id => index
        }
        root[:children] << parent_node
        index += 1
      end
      
      this_node = search_in_tree(root) { |n| n[:label] == label }
      if this_node.nil?
        this_node = {
          :children => []
        }
      else
        this_node[:parent][:children].delete this_node
      end
      
      this_node[:label] = label
      this_node[:priority] = menu_options.fetch(:priority, 10)
      this_node[:parent] = parent_node
      this_node[:controller] = "admin_#{controller.slashadmin_model_name.underscore}"
      this_node[:id] = index
      parent_node[:children] << this_node
      
      index += 1
    end
    
    sort_tree root
    
    root
  end
  
  def page_title(title)
    content_for(:title, title)

    buffer = ''.html_safe

    unless @breadcrumbs_trail.nil?
      buffer.safe_concat render(:partial => 'admin/breadcrumbs', :locals => { :trail => @breadcrumbs_trail, :title => content_for(:title) })
    end
    buffer.safe_concat content_tag(:h1, title, :class => 'page-header')
  end
  
  def breadcrumbs(&block)
    if block_given?
      builder = BreadcrumbBuilder.new

      yield builder

      @breadcrumbs_trail = builder.list
    else
      @breadcrumbs_trail = {}
    end
  end

  def render_action_items
    buffer = ''.html_safe

    @layout.action_items.each do |action|
      next unless action.visible? controller.action_name.to_sym

      context = Arbre::Context.new({}, self)
      context.build do |where|
        where.instance_exec(&action.block)
      end

      buffer.safe_concat context.to_s
      buffer.safe_concat ' '.html_safe
    end

    buffer
  end
 
  private
  
  def search_in_tree(node, &block)
    found = nil
    if block.call(node)
      found = node
    else
      node[:children].each do |child|
        found = search_in_tree(child, &block)
        break unless found.nil?
      end
    end
      
    found
  end
  
  def sort_tree(node)
    node[:children].sort! do |a, b|
      [a[:priority], a[:label]] <=> [b[:priority], b[:label]]
    end
      
    node[:children].each &method(:sort_tree)
  end
end