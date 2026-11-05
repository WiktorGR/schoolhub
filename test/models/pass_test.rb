require "test_helper"

class PassTest < ActiveSupport::TestCase
  test "a new pass starts with all entries" do
    pass = users(:two).passes.create!(entries_total: 10)

    assert_equal 10, pass.entries_remaining
  end

  test "requires a positive number of entries" do
    pass = users(:two).passes.new(entries_total: 0)

    assert_not pass.valid?
    assert pass.errors.of_kind?(:entries_total, :greater_than)
  end

  test "only participants get passes" do
    pass = users(:instructor).passes.new(entries_total: 5)

    assert_not pass.valid?
    assert pass.errors.of_kind?(:user, :not_a_participant)
  end

  test "using an entry decrements the remaining entries" do
    pass = passes(:one_new)

    pass.use_entry!

    assert_equal 7, pass.reload.entries_remaining
  end

  test "an empty pass cannot be used" do
    assert_raises(ArgumentError) { passes(:three_empty).use_entry! }
    assert_equal 0, passes(:three_empty).reload.entries_remaining
  end

  test "database never lets entries drop below zero" do
    assert_raises(ActiveRecord::StatementInvalid) do
      passes(:three_empty).update_column(:entries_remaining, -1)
    end
  end

  test "database never lets remaining entries exceed the total" do
    assert_raises(ActiveRecord::StatementInvalid) do
      passes(:one_new).update_column(:entries_remaining, 9)
    end
  end
end
