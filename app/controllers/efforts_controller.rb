class EffortsController < ApplicationController
  include TreePositioning

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

    if @effort.save
      respond_to do |format|
        format.html { redirect_to project_efforts_path(@project), notice: "Effort was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Effort was successfully created." }
      end
    else
      respond_to do |format|
        @efforts = @project.efforts.roots.includes(:children)
        @is_edit = true
        format.html { render :index, status: :unprocessable_content }
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
    if update_effort
      respond_to do |format|
        format.html { redirect_to project_efforts_path(@project), notice: "Effort was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Effort was successfully updated." }
      end
    else
      respond_to do |format|
        @efforts = @project.efforts.roots.includes(:children)
        @is_edit = true
        format.html { render :index, status: :unprocessable_content }
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

  def update_effort
    @effort.transaction do
      other_params = effort_params
      if effort_params.key?(:parent_id) || effort_params.key?(:position)
        new_parent_id = effort_params[:parent_id]
        new_position = effort_params[:position].to_i

        unless update_tree_position @effort, @project.efforts, new_position, new_parent_id, lambda { |parent_id| @project.efforts.find(parent_id) }
          @effort.errors.add(:base, "Invalid effort position")
          raise ActiveRecord::Rollback
        end
      else
        other_params = effort_params
      end

      return true if other_params.empty?
      @effort.update(other_params)
    end
  rescue ActiveRecord::Rollback
    false
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_effort
    @effort = @project.efforts.find(params[:id])
  end

  def effort_params
    params.require(:effort).permit(:title, :description, :parent_id, :position)
  end
end
