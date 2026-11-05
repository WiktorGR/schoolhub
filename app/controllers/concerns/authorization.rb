module Authorization
  extend ActiveSupport::Concern

  class_methods do
    # Usage: require_role :admin, or require_role :admin, :instructor, only: :show
    def require_role(*roles, **options)
      before_action(-> { authorize_role!(roles) }, **options)
    end
  end

  private
    def authorize_role!(roles)
      return if roles.map(&:to_s).include?(Current.user.role)

      redirect_to root_path, alert: "Nie masz dostępu do tej strony."
    end
end
