class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :lesson, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true
      t.boolean :present, null: false, default: false
      # The pass an entry was taken from; nil when nothing was charged.
      t.references :pass, foreign_key: true

      t.timestamps
    end
    # One attendance row per participant and lesson, so a resubmitted form updates it instead of adding another.
    add_index :attendances, [ :lesson_id, :user_id ], unique: true
  end
end
