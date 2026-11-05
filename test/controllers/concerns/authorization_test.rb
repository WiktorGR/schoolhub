require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  # Minimal controllers that exist only in this test, so the concern can be
  # checked before any real admin pages are built.
  class AdminOnlyController < ApplicationController
    require_role :admin

    def index
      head :ok
    end
  end

  class StaffController < ApplicationController
    require_role :admin, :instructor, only: :index

    def index
      head :ok
    end

    def show
      head :ok
    end
  end

  test "guest is sent to the sign in page" do
    with_test_routes do
      get "/admin_only"

      assert_redirected_to new_session_path
    end
  end

  test "participant is denied admin-only access" do
    with_test_routes do
      sign_in_as users(:one)

      get "/admin_only"

      assert_redirected_to root_path
      assert_equal "Nie masz dostępu do tej strony.", flash[:alert]
    end
  end

  test "instructor is denied admin-only access" do
    with_test_routes do
      sign_in_as users(:instructor)

      get "/admin_only"

      assert_redirected_to root_path
    end
  end

  test "admin is allowed admin-only access" do
    with_test_routes do
      sign_in_as users(:admin)

      get "/admin_only"

      assert_response :ok
    end
  end

  test "any of several roles is allowed" do
    with_test_routes do
      sign_in_as users(:instructor)

      get "/staff"

      assert_response :ok
    end
  end

  test "participant is denied when several roles are required" do
    with_test_routes do
      sign_in_as users(:one)

      get "/staff"

      assert_redirected_to root_path
    end
  end

  test "only: limits the check to the listed actions" do
    with_test_routes do
      sign_in_as users(:one)

      get "/staff/1"

      assert_response :ok
    end
  end

  private
    def with_test_routes(&block)
      with_routing do |set|
        set.draw do
          get "admin_only", to: "authorization_test/admin_only#index"
          get "staff", to: "authorization_test/staff#index"
          get "staff/:id", to: "authorization_test/staff#show"
          resource :session
          root "home#index"
        end

        block.call
      end
    end
end
