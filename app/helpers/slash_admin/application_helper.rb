module SlashAdmin
  module ApplicationHelper
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
        menu_options = controller.slashadmin_menu
        next if !menu_options || (menu_options.include?(:if) && !menu_options[:if].call)
        
        label = menu_options.fetch(:label, controller.slashadmin_model_name)
        label = label.call if label.respond_to? :call
        
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
    
    def brand
      brand = SlashAdmin::Engine.config.brand
      if brand.respond_to? :call
        instance_exec &brand
      else
        brand
      end
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
end
