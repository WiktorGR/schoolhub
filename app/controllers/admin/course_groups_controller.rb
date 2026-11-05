module Admin
  class CourseGroupsController < BaseController
    before_action :set_course, only: %i[ new create ]
    before_action :set_course_group, only: %i[ show edit update destroy ]
    before_action :set_instructors, only: %i[ new create edit update ]

    def show
      @active_enrollments = @course_group.enrollments.active.includes(:user).order(:created_at)
      @waitlisted_enrollments = @course_group.enrollments.waitlisted.includes(:user).in_waitlist_order
      @lessons = @course_group.lessons.upcoming
    end

    def new
      @course_group = @course.course_groups.new
    end

    def create
      @course_group = @course.course_groups.new(course_group_params)

      if @course_group.save
        redirect_to admin_course_group_path(@course_group), notice: "Grupa została dodana."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # A larger capacity frees seats, which go to the waitlist straight away.
      promoted = @course_group.with_lock do
        @course_group.update(course_group_params) && @course_group.fill_free_seats_from_waitlist
      end

      if promoted
        promoted.each { |enrollment| EnrollmentMailer.promoted(enrollment).deliver_later }
        redirect_to admin_course_group_path(@course_group), notice: "Grupa została zapisana."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @course_group.destroy
        redirect_to admin_course_path(@course_group.course), notice: "Grupa została usunięta.", status: :see_other
      else
        redirect_to admin_course_group_path(@course_group), alert: @course_group.errors.full_messages.to_sentence, status: :see_other
      end
    end

    private
      def set_course
        @course = Course.find(params.expect(:course_id))
      end

      def set_course_group
        @course_group = CourseGroup.includes(:course, :instructor).find(params.expect(:id))
      end

      def set_instructors
        @instructors = User.instructor.order(:name)
      end

      def course_group_params
        params.expect(course_group: [ :name, :capacity, :instructor_id ])
      end
  end
end
