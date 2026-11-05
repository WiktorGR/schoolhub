require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "new users are participants by default" do
    user = User.new

    assert user.participant?
  end

  test "is invalid with an unknown role" do
    user = users(:one)
    user.role = "superuser"

    assert_not user.valid?
    assert user.errors.added?(:role, :inclusion, value: "superuser")
  end

  test "database rejects an unknown role value" do
    assert_raises(ActiveRecord::StatementInvalid) do
      users(:one).update_column(:role, 99)
    end
  end

  test "requires a unique email address regardless of case" do
    user = User.new(email_address: users(:one).email_address.upcase, password: "secret123")

    assert_not user.valid?
    assert user.errors.added?(:email_address, :taken, value: users(:one).email_address)
  end

  test "requires a valid email address format" do
    user = User.new(email_address: "not-an-email", password: "secret123")

    assert_not user.valid?
    assert user.errors.of_kind?(:email_address, :invalid)
  end

  test "requires a password of at least 8 characters" do
    user = User.new(email_address: "new@example.com", password: "short")

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "uses grammatical Polish error messages" do
    user = User.new(email_address: users(:one).email_address, password: "secret123", password_confirmation: "other123")

    user.validate

    assert_includes user.errors.full_messages, "Adres e-mail jest już zajęty"
    assert_includes user.errors.full_messages, "Powtórzenie hasła nie zgadza się z hasłem"
  end
end
