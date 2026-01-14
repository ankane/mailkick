ActiveRecord::Schema.define do
  create_table :mailkick_opt_outs do |t|
    t.string :email, null: false
    t.bigint :company_id, null: false
    t.string :list, null: false, default: "marketing"
    t.timestamps null: false
  end
  add_index :mailkick_opt_outs, [:email, :company_id, :list], unique: true, name: "index_mailkick_opt_outs_on_email_company_and_list"
  add_index :mailkick_opt_outs, :company_id
  add_index :mailkick_opt_outs, :email

  create_table :users do |t|
    t.string :email
  end

  create_table :admins do |t|
    t.string :email
  end

  create_table :companies do |t|
    t.string :name
  end
end
