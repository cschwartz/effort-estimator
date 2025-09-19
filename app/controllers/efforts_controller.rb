class EffortsController < ApplicationController
  before_action :set_project
  before_action :set_effort, only: [ :edit, :update, :destroy ]

  def index
    @efforts = @project.efforts.roots.includes(:children)
    @effort = nil
    @is_edit = false
  end

  def new
    @efforts = @project.efforts.roots.includes(:children)
    @parent = @project.efforts.find(params[:parent_id]) if params[:parent_id].present?
    @effort = @project.efforts.build(parent: @parent)
    @is_edit = true

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream
    end
  end

  def create
    @effort = @project.efforts.build(effort_params)

    if params[:parent_id].present?
      @effort.parent = @project.efforts.find(params[:parent_id])
    end

    if @effort.save
      respond_to do |format|
        format.html { redirect_to project_efforts_path(@project), notice: "Effort was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Effort was successfully created." }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.turbo_stream { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit
    @efforts = @project.efforts.roots.includes(:children)
    @is_edit = true

    respond_to do |format|
      format.html { render :index }
    end
  end

  def show
      @efforts = @project.efforts.roots.includes(:children)
      @effort = @project.efforts.find(params[:id])
      @is_edit = false

      respond_to do |format|
        format.html { render :index }
        format.turbo_stream
      end
  end

  def update
    if @effort.update(effort_params)
      respond_to do |format|
        format.html { redirect_to project_efforts_path(@project), notice: "Effort was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Effort was successfully updated." }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @effort.destroy
    respond_to do |format|
      format.html { redirect_to project_efforts_path(@project), notice: "Effort was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Effort was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_effort
    @effort = @project.efforts.find(params[:id])
  end

  def effort_params
    params.require(:effort).permit(:title, :description, :parent_id)
  end
end
