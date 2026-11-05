module Admin
  class PassesController < BaseController
    before_action :set_user

    def new
      @pass = @user.passes.new
    end

    def create
      @pass = @user.passes.new(pass_params)

      if @pass.save
        redirect_to edit_admin_user_path(@user), notice: "Wydano karnet na #{@pass.entries_total} wejść."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private
      def set_user
        @user = User.find(params.expect(:user_id))
      end

      def pass_params
        params.expect(pass: [ :entries_total ])
      end
  end
end
