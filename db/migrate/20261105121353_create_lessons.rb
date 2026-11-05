class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.references :course_group, null: false, foreign_key: true, index: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :topic

      t.timestamps
    end
    # Serves "lessons of a group in time order"; course_group_id comes first so it also covers FK lookups.
    add_index :lessons, [ :course_group_id, :starts_at ]
    add_index :lessons, :starts_at
    add_check_constraint :lessons, "ends_at > starts_at", name: "lessons_end_after_start"
  end
end
