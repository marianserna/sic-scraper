class ResolutionsController < ApplicationController
  def index
    scope = Resolution.extracted
    scope = scope.search(params[:q]) if params[:q].present?
    @resolutions = scope
  end

  def show
    @resolution = Resolution.find(params[:id])
  end
end
