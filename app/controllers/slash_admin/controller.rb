module SlashAdmin
  class Controller < SlashAdminController
    include BatchActions
    include SlashAdmin::Setup
    include SlashAdmin::DSL

    before_filter :evaluate_blocks
    attr_reader :object, :objects, :q

    def self.initialize_slashadmin_controller
      batch_action :destroy do |objects|
        objects.each &:destroy
      end
    end

    # ACTIONS
    def index
      @q = slashadmin_model.search(params[:q])
      @objects = @q.result(:distinct => true).page(params[:page])

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
          format.html { redirect_to(@object, :notice => I18n.t('admin.flash.created', :model => slashadmin_model.model_name.human)) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @object = slashadmin_model.find(params[:id])
      updated = @object.update_attributes(slashadmin_params)
      
      respond_to do |format|
        if updated
          format.html { redirect_to(@object, :notice => I18n.t('admin.flash.updated', :model => slashadmin_model.model_name.human)) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def destroy
      @object = slashadmin_model.find(params[:id])
      @object.destroy
      
      respond_to do |format|
        format.html { redirect_to :action => "index" }
      end
    end

    def show
      @object = slashadmin_model.find(params[:id])

      if self.class.slashadmin_show.nil?
        @page = render_to_string(:partial => "/admin/show/default_show").html_safe
      else
        page = nil

        view_context.instance_exec do
          define_singleton_method(@object.class.model_name.singular) { @object }

          context = Arbre::Context.new({}, self)
          context.instance_exec(@object, &controller.slashadmin_show)
          page = context.to_s
        end

        @page = page
      end

      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/show" }
      end
    end

    def edit
      @object = slashadmin_model.find(params[:id])
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

    def action_missing(action, *args)
      @routing.custom_actions.each do |custom_action|
        if custom_action.name.to_s == action
          return slashadmin_invoke_custom_action custom_action, *args
        end
      end

      raise AbstractController::ActionNotFound, "Custom action #{action} is not defined"
    end

    protected

    def slashadmin_invoke_custom_action(custom_action, *args)
      if custom_action.options[:on] == :member
        @object = slashadmin_model.find(params[:id])
      end

      if custom_action.block.nil?
        @page = render_to_string("/admin/#{slashadmin_model.model_name.plural}/#{custom_action.name}", :layout => false).html_safe
      

        respond_to do |format|
          format.html { render :layout => "admin", :template => "admin/show" }
        end
      else
        instance_exec *args, &custom_action.block
      end
    end

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

    private

    def evaluate_blocks
      @layout = self.slashadmin_layout
      @routing = self.slashadmin_routing
    end
  end
end
