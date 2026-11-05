class CreatePasses < ActiveRecord::Migration[8.1]
  def change
    create_table :passes do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :entries_total, null: false
      t.integer :entries_remaining, null: false

      t.timestamps
    end
    add_check_constraint :passes, "entries_total > 0", name: "passes_entries_total_positive"
    # The last line of defence for "entries never drop below zero".
    add_check_constraint :passes, "entries_remaining BETWEEN 0 AND entries_total", name: "passes_entries_remaining_in_range"
  end
end
