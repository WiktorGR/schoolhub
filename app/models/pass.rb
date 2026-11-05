class Pass < ApplicationRecord
  belongs_to :user
  has_many :attendances, dependent: :restrict_with_error

  validates :entries_total, numericality: { only_integer: true, greater_than: 0 }
  validates :entries_remaining, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :remaining_cannot_exceed_total
  validate :user_must_be_a_participant, on: :create

  before_validation :start_with_all_entries, on: :create

  scope :with_entries_left, -> { where(entries_remaining: 1..) }

  def use_entry!
    raise ArgumentError, "pass #{id} has no entries left" if entries_remaining.zero?

    decrement!(:entries_remaining)
  end

  def return_entry!
    increment!(:entries_remaining)
  end

  private
    # A new pass always starts full; only the total comes from the form.
    def start_with_all_entries
      self.entries_remaining = entries_total
    end

    def remaining_cannot_exceed_total
      if entries_remaining && entries_total && entries_remaining > entries_total
        errors.add(:entries_remaining, :less_than_or_equal_to, count: entries_total)
      end
    end

    def user_must_be_a_participant
      errors.add(:user, :not_a_participant) if user && !user.participant?
    end
end
