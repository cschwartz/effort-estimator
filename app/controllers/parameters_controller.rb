class ParametersController < ApplicationController
  before_action :set_project
  before_action :set_parameter, only: [ :show, :edit, :update, :destroy ]

  def index
    @parameters = @project.parameters.order(:created_at)
  end

  def show
  end

  def new
    @parameter = @project.parameters.build
  end

  def create
    @parameter = @project.parameters.build(parameter_params)

    if @parameter.save
      respond_to do |format|
        format.html { redirect_to project_parameters_path(@project), notice: "Parameter was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Parameter was successfully created." }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @parameter.update(parameter_params)
      respond_to do |format|
        format.html { redirect_to project_parameters_path(@project), notice: "Parameter was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Parameter was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @parameter.destroy
    respond_to do |format|
      format.html { redirect_to project_parameters_path(@project), notice: "Parameter was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Parameter was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_parameter
    @parameter = @project.parameters.find(params[:id])
  end

  def parameter_params
    params.require(:parameter).permit(:title)
  end
end
