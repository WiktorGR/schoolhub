module Admin
  # Every controller in the admin namespace inherits the admin-only check from here.
  class BaseController < ApplicationController
    require_role :admin
  end
end
