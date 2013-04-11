module SlashAdmin
  module ApplicationHelper
    class BreadcrumbBuilder
      attr_reader :list

      def initialize
        @list = {}
      end

      def trail(name, path)
        @list[name] = path
      end
    end

    def self.config_helper(*names)
      names.each do |name|
        define_method(name) do 
          value = SlashAdmin::Engine.config.send(name)
          if value.respond_to? :call
            instance_exec &value
          else
            value
          end
        end
      end
    end
  
    config_helper :brand, :brand_url
    
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
    
    def model_name(options = {})
      controller.slashadmin_model.model_name.human(options)
    end

    def attribute_name(attribute, options = {})
      controller.slashadmin_model.human_attribute_name(attribute, options)
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
   
    def slashadmin_default_inputs(include_readonly = false)
      columns = []
        
      controller.slashadmin_model.columns.each do |column|
        next if !include_readonly && (column.primary || column.name == "created_at" || column.name == "updated_at")
        columns << [ :input, column.name ]
      end
        
      drop = Set[]
      associate = {}

      controller.slashadmin_model.reflect_on_all_associations.each do |assoc|
        unless include_readonly || assoc.counter_cache_column.nil?
          drop << assoc.counter_cache_column
        end

        if assoc.belongs_to?
          associate[assoc.foreign_key] = assoc.name
        end
      end

      columns.reject! { |name| drop.include? name }
      columns.map! do |name|
        assoc = associate[name[1]]
        if name[0] == :input && !assoc.nil?
          [ :association, assoc ]
        else
          name
        end
      end
      
      columns
    end
 
    def render_index_batch_select(object)
      render(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object })
    end

    def render_default_index_actions(object)
      render(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object })
    end

    def slashadmin_show_for(record, options = {}, &block)
      SlashAdmin::ShowFor.apply_config do
        show_for record, options, &block
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
