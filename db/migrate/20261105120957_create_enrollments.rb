class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course_group, null: false, foreign_key: true, index: false
      t.integer :status, null: false
      t.datetime :cancelled_at

      t.timestamps
    end

    # At most one active or waitlisted enrollment per participant and group.
    # Cancelled rows are excluded, so a participant can enroll again later.
    add_index :enrollments, [ :course_group_id, :user_id ], unique: true,
              where: "status IN (0, 1)", name: "index_enrollments_one_open_per_user_and_group"
    # Serves seat counting and waitlist ordering within a group.
    add_index :enrollments, [ :course_group_id, :status, :created_at ]
    add_check_constraint :enrollments, "status IN (0, 1, 2)", name: "enrollments_status_check"
  end
end
