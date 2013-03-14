module SlashAdmin
  class Controller < ActionController::Base
    include BatchActions

    class << self
      attr_reader :slashadmin_model

      def admin(model)
        @slashadmin_model = model
        batch_model model

        include_admin_set SlashAdmin::Base
      end

      private

      def include_admin_set(set)
        set.constants(false).each do |constant|
          include(set.const_get(constant))
        end
      end
    end

    def slashadmin_model
      self.class.slashadmin_model
    end

    protected

    def fetch_index
      slashadmin_model.all
    end
  end
end
