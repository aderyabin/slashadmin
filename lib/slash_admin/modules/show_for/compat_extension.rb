SlashAdmin.extension(:ActiveAdmin, :ShowFor) do
  def attributes_table_default_record
    ActiveSupport::Deprecation.warn("attributes_table with implicit record is deprecated. Use attributes_table(@object).")
    @object
  end
end