class AddNameToUsers < ActiveRecord::Migration[8.1]
  def change
    # The temporary default fills existing rows; new rows must always provide a name.
    add_column :users, :name, :string, null: false, default: ""
    change_column_default :users, :name, from: "", to: nil
  end
end
