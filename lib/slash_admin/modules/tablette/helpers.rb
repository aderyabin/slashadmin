class Tablette::Table
  def batch_select
    column :select, :title => "Select" do |object|
      render_index_batch_select object
    end
  end
  
  def default_actions
    column :actions, :title => "Actions" do |object|
      render_default_index_actions object
    end
  end
end
