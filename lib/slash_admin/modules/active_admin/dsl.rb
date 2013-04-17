SlashAdmin.extension(:ActiveAdmin, :DSL) do
  module self::ClassMethods
    def controller(&block)
      ActiveSupport::Deprecation.warn("controller method is deprecated. Include code from a block in the class body instead.")

      instance_exec &block
    end

    def menu(options = {})
      ActiveSupport::Deprecation.warn("menu method is deprecated. Use layout block instead.")

      options = { :hidden => true } if options == false

      activeadmin_menu.merge! options
    end

    def scope(*args, &block)
      ActiveSupport::Deprecation.warn("scope method is deprecated. Use layout block instead.")

      activeadmin_scopes << [ args, block ]
    end

    def filter(*args)
      ActiveSupport::Deprecation.warn("filter method is deprecated. Use layout block instead.")

      activeadmin_filters << args
    end

    def action_item(*args, &block)
      ActiveSupport::Deprecation.warn("action_item method is deprecated. Use layout block instead.")

      activeadmin_action_items << [ args, block ]
    end      

    def actions(*list)
      ActiveSupport::Deprecation.warn("actions method is deprecated. Use routing block instead.")      

      activeadmin_default_actions[:only] = list
    end

    def member_action(*args, &block)
      ActiveSupport::Deprecation.warn("member_action method is deprecated. Use routing block instead.")

      activeadmin_member_actions << [ args, block ]
    end

    def collection_action(*args, &block)
      ActiveSupport::Deprecation.warn("collection_action method is deprecated. Use routing block instead.")

      activeadmin_collection_actions << [ args, block ]
    end

    def activeadmin_menu;               @activeadmin_menu    ||= {}; end
    def activeadmin_scopes;             @activeadmin_scopes  ||= []; end
    def activeadmin_filters;            @activeadmin_filters ||= []; end
    def activeadmin_action_items;       @activeadmin_action_items ||= []; end
    def activeadmin_default_actions;    @activeadmin_default_actions ||= {}; end
    def activeadmin_member_actions;     @activeadmin_member_actions ||= []; end
    def activeadmin_collection_actions; @activeadmin_collection_actions ||= []; end
  end

  included do
    klass = self

    layout do
      menu klass.activeadmin_menu

      klass.activeadmin_scopes.each do |(args, block)|
        scope *args, &block
      end

      klass.activeadmin_filters.each do |args|
        filter *args
      end

      klass.activeadmin_action_items.each do |(args, block)|
        action_item *args, &block
      end
    end

    routing do
      default_actions klass.activeadmin_default_actions

      klass.activeadmin_member_actions.each do |(args, block)|
        member_action *args, &block
      end

      klass.activeadmin_collection_actions.each do |(args, block)|
        collection_action *args, &block
      end

      enabled = klass.config.batch_actions
      unless enabled.nil?
        ActiveSupport::Deprecation.warn("config.batch_actions= method is deprecated. Use routing block instead.")

        batch_actions enabled
      end
    end
  end
end
