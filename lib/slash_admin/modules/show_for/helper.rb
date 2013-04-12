SlashAdmin.view_helper(:ShowFor) do
  def slashadmin_show_for(record, options = {}, &block)
    SlashAdmin::ShowFor.apply_config do
      show_for record, options, &block
    end
  end
end
