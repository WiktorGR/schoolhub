module Admin
  class CoursesController < BaseController
    before_action :set_course, only: %i[ show edit update destroy ]

    def index
      @courses = paginate(Course.order(:name))
    end

    def show
      @course_groups = @course.course_groups.includes(:instructor).order(:name)
    end

    def new
      @course = Course.new
    end

    def create
      @course = Course.new(course_params)

      if @course.save
        redirect_to admin_course_path(@course), notice: "Kurs został dodany."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @course.update(course_params)
        redirect_to admin_course_path(@course), notice: "Kurs został zapisany."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @course.destroy
        redirect_to admin_courses_path, notice: "Kurs został usunięty.", status: :see_other
      else
        redirect_to admin_course_path(@course), alert: "Nie można usunąć kursu, który ma grupy.", status: :see_other
      end
    end

    private
      def set_course
        @course = Course.find(params.expect(:id))
      end

      def course_params
        params.expect(course: [ :name, :description ])
      end
  end
end
