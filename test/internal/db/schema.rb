# must go here to take effect before schema loaded
if ActiveRecord::VERSION::MAJOR < 6 && ActiveRecord::ConnectionAdapters::SQLite3Adapter.respond_to?(:represent_boolean_as_integer=)
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
end

ActiveRecord::Schema.define do
  create_table :mailkick_subscriptions do |t|
    t.references :subscriber, polymorphic: true, index: false
    t.string :list
    t.timestamps null: false
  end
  add_index :mailkick_subscriptions, [:subscriber_type, :subscriber_id, :list], unique: true, name: "index_mailkick_subscriptions_on_subscriber_and_list"

  create_table :mailkick_opt_outs do |t|
    t.string :email
    t.references :user, polymorphic: true
    t.boolean :active, null: false, default: true
    t.string :reason
    t.string :list
    t.timestamps null: false
  end

  add_index :mailkick_opt_outs, :email

  create_table :users do |t|
    t.string :email
  end

  create_table :admins do |t|
    t.string :email_address
  end
end
