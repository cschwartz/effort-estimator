class CategoriesController < ApplicationController
  before_action :set_project
  before_action :set_category, only: [ :show, :edit, :update, :destroy ]

  def index
    @categories = @project.categories.order(:created_at)
  end

  def show
  end

  def new
    @category = @project.categories.build
  end

  def create
    @category = @project.categories.build(category_params)

    if @category.save
      respond_to do |format|
        format.html { redirect_to project_categories_path(@project), notice: "Category was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Category was successfully created." }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to project_categories_path(@project), notice: "Category was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Category was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to project_categories_path(@project), notice: "Category was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Category was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_category
    @category = @project.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:title, :category_type)
  end
end
