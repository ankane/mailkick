ActiveRecord::Schema.define do
  create_table :mailkick_subscriptions do |t|
    t.references :subscriber, polymorphic: true, index: false
    t.string :list
    t.timestamps null: false
  end
  add_index :mailkick_subscriptions, [:subscriber_type, :subscriber_id, :list], unique: true, name: "index_mailkick_subscriptions_on_subscriber_and_list"

  create_table :users do |t|
    t.string :email
  end

  create_table :admins do |t|
    t.string :email
  end
end
