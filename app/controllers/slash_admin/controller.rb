module SlashAdmin
  class Controller < ApplicationController
    include BatchActions
    attr_reader :attributes_table_default_record

    class << self
      attr_reader :slashadmin_model
      attr_accessor :slashadmin_index, :slashadmin_show, :slashadmin_form

      def admin(model)
        @slashadmin_model = model
        batch_model model

        include_admin_set SlashAdmin::Base
        
        alias_name = "Admin#{model.name}Controller"
        SlashAdmin.const_set alias_name, self
        
        unless Rails.application.config.cache_classes
          ActiveSupport::Dependencies.autoloaded_constants << self.name << "SlashAdmin::#{alias_name}"
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

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end

    # ACTION DSL
    def self.index(&block); self.slashadmin_index = block; end
    def self.show(&block); self.slashadmin_show = block; end
    def self.form(&block); self.slashadmin_form = block; end

    # ACTIONS
    def index
      render_index_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/index" }
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
      object = self.fetch_show
      render_edit_partial(object)
      
      @object = object
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/edit" }
      end
    end

    protected

    # EXTENSION HELPERS

    def fetch_index
      slashadmin_model.all
    end
  
    def fetch_show
      slashadmin_model.find(params[:id])
    end
  end
end
