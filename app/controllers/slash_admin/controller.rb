module SlashAdmin
  class Controller < ApplicationController
    include BatchActions
    include SlashAdmin::Setup
    include SlashAdmin::DSL
    include SlashAdmin::ExtensionHelpers
    include SlashAdmin::Authentication
    
    helper :all
    attr_reader :attributes_table_default_record
    def self.initialize_slashadmin_controller
      @slashadmin_menu = {}
        
      batch_action :destroy do |objects|
        objects.each &:destroy
      end
    end

    # ACTIONS
    def index
      render_index_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/index" }
      end
    end

    def new
      @object = slashadmin_restrict.new
      render_form_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/new" }
      end
    end

    def create
      @object = slashadmin_restrict.new(slashadmin_params)
      
      respond_to do |format|
        if @object.save
          format.html { redirect_to(@object, :notice => "#{slashadmin_model_name} was successfully created.") }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @object = self.fetch_show
      
      respond_to do |format|
        if @object.update_attributes(slashadmin_params)
          format.html { redirect_to(@object, :notice => "#{slashadmin_model_name} was successfully updated.") }
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
      name = slashadmin_model_name.underscore
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
  end
end
