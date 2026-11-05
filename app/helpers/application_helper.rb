module ApplicationHelper
  def role_name(role)
    t("roles.#{role}")
  end

  def role_options
    User.roles.keys.map { |role| [ role_name(role), role ] }
  end
end
