class Tablette::Table
  def selectable_column
    column :select, :title => "Select" do |object|
      render_selectable_column object
    end
  end
  
  def default_actions
    column :actions, :title => "Actions" do |object|
      render_default_index_actions object
    end
  end
end
