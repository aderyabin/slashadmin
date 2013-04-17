module SlashAdmin
  class Controller < SlashAdminController
    include BatchActions
    include SlashAdmin::Setup
    include SlashAdmin::DSL
    include SlashAdmin::Restrictions

    def self.initialize_slashadmin_controller
      batch_action :destroy do |objects|
        objects.each &:destroy
      end
    end

    # ACTIONS
    def index
      @q = slashadmin_unrestrict(slashadmin_restrict(self.class.slashadmin_model)).search(params[:q])
      @objects = @q.result(:distinct => true).page(params[:page])
      @filters =
        slashadmin_filters
      
      render_index_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/index" }
      end
    end

    def new
      @object = slashadmin_unrestrict(slashadmin_restrict.new)
      render_form_partial
      
      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/new" }
      end
    end

    def create
      @object = slashadmin_unrestrict(slashadmin_restrict.new(slashadmin_params))
      
      respond_to do |format|
        if @object.save
          format.html { redirect_to(@object, :notice => I18n.t('admin.flash.created', :model => slashadmin_model.model_name.human)) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      object = slashadmin_restrict.find(params[:id])
      updated = object.update_attributes(slashadmin_params)
      @object = slashadmin_unrestrict(object)
      
      respond_to do |format|
        if updated
          format.html { redirect_to(@object, :notice => I18n.t('admin.flash.updated', :model => slashadmin_model.model_name.human)) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def destroy
      @object = slashadmin_restrict.find(params[:id])
      @object.destroy
      
      respond_to do |format|
        format.html { redirect_to :action => "index" }
      end
    end

    def show
      @object = slashadmin_unrestrict(slashadmin_restrict.find(params[:id]))
      if self.class.slashadmin_show.nil?
        @page = render_to_string(:partial => "/admin/show/default_show").html_safe
      else
        context = Arbre::Context.new({}, self)
        context.instance_exec(@object, &self.class.slashadmin_show)
        @page = context.to_s
      end

      respond_to do |format|
        format.html { render :layout => "admin", :template => "admin/show" }
      end
    end

    def edit
      @object = slashadmin_unrestrict(slashadmin_restrict.find(params[:id]))
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
