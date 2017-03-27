class <%= migration_class_name %> < ActiveRecord::Migration<% if ActiveRecord::VERSION::MAJOR >= 5 %>[<%=ActiveRecord::Migration.current_version%>]<% end %>
  def change
    create_table :mailkick_opt_outs do |t|
      t.string :email
      t.integer :user_id
      t.string :user_type
      t.boolean :active, null: false, default: true
      t.string :reason
      t.string :list

      <% if ActiveRecord::VERSION::MAJOR >= 5 || (ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 2)%>t.timestamps null: false<% else %>t.timestamps<% end %>
    end

    add_index :mailkick_opt_outs, :email
    add_index :mailkick_opt_outs, [:user_id, :user_type]
  end
end
