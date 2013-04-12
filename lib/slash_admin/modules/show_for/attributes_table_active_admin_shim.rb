SlashAdmin.shim_for(SlashAdmin::ShowFor::AttributesTable, if: -> { SlashAdmin.compatible_with? :activeadmin }) do
  included do
    alias_method_chain :build, :activeadmin
  end

  def build_with_activeadmin(*args)
   case args.length
    when 0
      record = attributes_table_default_record
      attributes = {}

    when 1
      if args[0].kind_of? Hash
        record = attributes_table_default_record
        attributes = args[0]
      else
        record = args[0]
        attributes = {}
      end
      
    when 2
      record, attributes = *args
      
    else
      raise ArgumentError, "0-2 arguments expected"
    end

    build_without_activeadmin(record, attributes)
  end
end
