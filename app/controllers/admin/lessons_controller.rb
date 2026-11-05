module Admin
  class LessonsController < BaseController
    before_action :set_course_group, only: %i[ new create ]
    before_action :set_lesson, only: %i[ edit update destroy ]

    def new
      @lesson = @course_group.lessons.new
    end

    def create
      @lesson = Lesson.create_weekly_series(lesson_params.merge(course_group: @course_group), weeks: params[:weeks])

      if @lesson.errors.none?
        redirect_to admin_course_group_path(@course_group), notice: "Zajęcia zostały dodane do harmonogramu."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @lesson.update(lesson_params)
        redirect_to admin_course_group_path(@lesson.course_group), notice: "Zajęcia zostały zapisane."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @lesson.destroy
        redirect_to admin_course_group_path(@lesson.course_group), notice: "Zajęcia zostały usunięte.", status: :see_other
      else
        redirect_to admin_course_group_path(@lesson.course_group), alert: "Nie można usunąć zajęć ze sprawdzoną obecnością.",
                                                                   status: :see_other
      end
    end

    private
      def set_course_group
        @course_group = CourseGroup.find(params.expect(:course_group_id))
      end

      def set_lesson
        @lesson = Lesson.includes(:course_group).find(params.expect(:id))
      end

      def lesson_params
        params.expect(lesson: [ :starts_at, :ends_at, :topic ])
      end
  end
end
