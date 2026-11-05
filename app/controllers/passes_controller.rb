class PassesController < ApplicationController
  require_role :participant

  def index
    @passes = Current.user.passes.order(created_at: :desc)
    @charged_attendances = Current.user.attendances.where.not(pass: nil)
                                  .includes(lesson: { course_group: :course })
                                  .order(created_at: :desc).limit(20)
  end
end
