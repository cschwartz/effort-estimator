class EstimationSessionsController < ApplicationController
  before_action :set_project
  before_action :set_estimation_session, except: [ :new, :create ]
  before_action :set_active_participants, only: [ :show ]

  def new
    @estimation_session = @project.build_estimation_session
    @estimation_options = EstimationOption.all
  end

  def create
    result = EstimationSessionCreator.call(
      project: @project,
      facilitator: current_user,
      estimation_option: EstimationOption.find(estimation_session_params[:estimation_option_id])
    )

    if result.success
      redirect_to project_estimation_session_path(@project), notice: "Estimation session started successfully."
    else
      @estimation_session = result.session
      @estimation_options = EstimationOption.all
      flash.now[:alert] = result.errors.join(", ")
      render :new, status: :unprocessable_content
    end
  end

  def show; end

  private

  def set_active_participants
    @active_participants = @estimation_session.session_participants.where(status: :active).includes(:user)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_estimation_session
    @estimation_session = @project.estimation_session
    redirect_to new_project_estimation_session_path(@project), alert: "No active estimation session" if @estimation_session.nil?
  end

  def estimation_session_params
    params.require(:estimation_session).permit(:estimation_option_id)
  end
end
