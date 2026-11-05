class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    # Mirrors the User role enum so invalid values are rejected even outside Rails.
    add_check_constraint :users, "role IN (0, 1, 2)", name: "users_role_check"
  end
end
