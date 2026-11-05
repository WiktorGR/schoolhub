class CreateCourseGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :course_groups do |t|
      # No separate index: the unique [course_id, name] index below also serves course_id lookups.
      t.references :course, null: false, foreign_key: true, index: false
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.integer :capacity, null: false

      t.timestamps
    end
    add_index :course_groups, [ :course_id, :name ], unique: true
    add_check_constraint :course_groups, "capacity > 0", name: "course_groups_capacity_positive"
  end
end
