module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[ edit update ]
    before_action :prevent_changing_own_role, only: %i[ edit update ]

    def index
      @users = User.order(:name)
      @users = @users.where(role: params[:role]) if User.roles.key?(params[:role])
      @users = paginate(@users)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Rola użytkownika #{@user.name} została zmieniona."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
      def set_user
        @user = User.find(params.expect(:id))
      end

      # Stops an admin from accidentally locking themselves out of the admin panel.
      def prevent_changing_own_role
        redirect_to admin_users_path, alert: "Nie możesz zmienić własnej roli." if @user == Current.user
      end

      def user_params
        params.expect(user: [ :role ])
      end
  end
end
