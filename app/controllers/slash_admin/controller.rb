module SlashAdmin
  class Controller < ApplicationController
    include BatchActions
    
    attr_reader :attributes_table_default_record

    class << self
      attr_reader :slashadmin_model
      attr_accessor :slashadmin_index, :slashadmin_show, :slashadmin_form, :slashadmin_permit_params, :slashadmin_menu

      def admin(model)
        @slashadmin_model = model
        batch_model model

        include_admin_set SlashAdmin::Base
        
        alias_name = "Admin#{model.name}Controller"
        SlashAdmin.const_set alias_name, self
        
        unless Rails.application.config.cache_classes
          ActiveSupport::Dependencies.autoloaded_constants << self.name << "SlashAdmin::#{alias_name}"
        end

        @slashadmin_menu = {}
        
        batch_action :destroy do |objects|
          objects.each &:destroy
        end
      end
    
      private

      def include_admin_set(set)
        set.constants(false).each do |constant|
          include(set.const_get(constant))
        end
      end
    end

    # CONTROLLER AND PARTIAL HELPERS
    def slashadmin_model
      self.class.slashadmin_model
    end
  
    def generate_menu
      root = {
        :label => "root",
        :children => [],
        :priority => 0,
        :parent => nil
      }
      
      search_in_tree = ->(node = root, &block) do
        found = nil
        if block.call(node)
          found = node
        else
          node[:children].each do |child|
            found = search_in_tree.call(child, &block)
            break unless found.nil?
          end
        end
        
        found
      end
      
      sort_tree = ->(node) do
        node[:children].sort! do |a, b|
          [a[:priority], a[:label]] <=> [b[:priority], b[:label]]
        end
        
        node[:children].each &sort_tree
      end
      
      SlashAdmin.each_controller do |controller|
        menu_options = controller.slashadmin_menu
        next if !menu_options || (menu_options.include?(:if) && !menu_options[:if].call)
        
        label = menu_options.fetch(:label, controller.slashadmin_model.name)
        label = label.call if label.respond_to? :call
        
        parent = menu_options.fetch(:parent, "root")
        
        parent_node = search_in_tree.call { |n| n[:label] == parent }
        if parent_node.nil?
          parent_node = {
            :label => parent,
            :children => [],
            :priority => 10,
            :parent => root
          }
          root[:children] << parent_node
        end
        
        this_node = search_in_tree.call { |n| n[:label] == label }
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
        this_node[:controller] = "admin_#{slashadmin_model.name.underscore}"
        parent_node[:children] << this_node
      end
      
      sort_tree.call root
      
      root
    end
  
    helper_method :generate_menu
  
    def render_index_batch_select(object)
      render_to_string(:layout => false, :partial => "admin/index/batch_select", :locals => { :object => object }).html_safe
    end

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end

    # ACTION DSL
    def self.index(&block); self.slashadmin_index = block; end
    def self.show(&block); self.slashadmin_show = block; end
    def self.form(&block); self.slashadmin_form = block; end
    def self.permit_params(*args); self.slashadmin_permit_params = args; end
    def self.menu(options = {}); self.slashadmin_menu = options; end

    # ACTIONS
    def index
      render_index_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/index" }
      end
    end

    def new
      @object = slashadmin_model.new
      render_form_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/new" }
      end
    end

    def create
      @object = slashadmin_model.new(slashadmin_params)
      
      respond_to do |format|
        if @object.save
          format.html { redirect_to(@object, :notice => "#{slashadmin_model.name} was successfully created.") }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @object = self.fetch_show
      
      respond_to do |format|
        if @object.update_attributes(slashadmin_params)
          format.html { redirect_to(@object, :notice => "#{slashadmin_model.name} was successfully updated.") }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def destroy
      @object = self.fetch_show
      @object.destroy
      
      respond_to do |format|
        format.html { redirect_to :action => "index" }
      end
    end

    def show
      object = self.fetch_show
      context = Arbre::Context.new({}, self)
      
      @attributes_table_default_record = object
      begin
        context.instance_exec(object, &self.class.slashadmin_show)
      ensure
        @attributes_table_default_record = nil
      end
      
      @page = context.to_s
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/show" }
      end
    end

    def edit
      @object = self.fetch_show
      render_form_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/edit" }
      end
    end

    def dispatch_batch
      send "batch_#{params[:batch_action]}"
      
      respond_to do |format|
        format.html { redirect_to :action => "index" }
      end
    end

    protected

    def slashadmin_params
      name = slashadmin_model.name.underscore
      allowed = self.class.slashadmin_permit_params
      
      if !params.respond_to?(:require)
        return params[name]
      end
      
      param_list = params.require(name)
      
      if allowed.nil?
        param_list.permit!
      elsif allowed.first.respond_to? :call
        param_list.permit(*allowed.first.call)
      else
        param_list.permit(*allowed)
      end
    end

    # EXTENSION HELPERS

    def fetch_index
      slashadmin_model.all
    end
  
    def fetch_show
      slashadmin_model.find(params[:id])
    end
  end
end
