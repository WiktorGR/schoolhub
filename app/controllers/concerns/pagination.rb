# Minimal offset pagination, so long lists stay fast without adding a gem.
module Pagination
  extend ActiveSupport::Concern

  PER_PAGE = 20

  included do
    helper_method :current_page, :total_pages
  end

  private
    attr_reader :current_page, :total_pages

    def paginate(scope, per_page: PER_PAGE)
      @total_pages = [ (scope.count / per_page.to_f).ceil, 1 ].max
      @current_page = params[:page].to_i.clamp(1, @total_pages)
      scope.limit(per_page).offset((@current_page - 1) * per_page)
    end
end
