class EstimationSessionsController < ApplicationController
  before_action :set_project
  before_action :set_estimation_session, except: [ :new, :create ]
  before_action :set_active_participants, only: [ :show ]
  before_action :set_current_effort_category_estimates, only: [ :show ]
  before_action :set_project_parameters, only: [ :show ]
  before_action :require_facilitator, only: [ :select_parameter ]
  before_action :set_current_estimate, only: [ :select_parameter ]

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

  def select_parameter
    parameter = @project.parameters.find(params[:parameter_id])
    result = EstimateStateTransitioner.select_parameter(estimate: @current_estimate, parameter: parameter)

    if result[:success]
      broadcast_parameter_selection_update(@current_estimate)

      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Parameter selected successfully." }
        format.html { redirect_to project_estimation_session_path(@project), notice: "Parameter selected successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = result[:errors].join(", ") }
        format.html { redirect_to project_estimation_session_path(@project), alert: result[:errors].join(", ") }
      end
    end
  end

  private

  def set_active_participants
    @active_participants = @estimation_session.session_participants.where(status: :active).includes(:user)
  end

  def set_current_effort_category_estimates
    if @estimation_session.current_effort
      @current_effort_category_estimates = @estimation_session.effort_estimates
        .where(effort: @estimation_session.current_effort)
        .includes(:category)
        .order(:category_id)
    else
      @current_effort_category_estimates = []
    end
  end

  def set_project_parameters
    @project_parameters = @project.parameters.order(:title)
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

  def require_facilitator
    unless @estimation_session.facilitator == current_user
      redirect_to project_estimation_session_path(@project), alert: "Only the facilitator can perform this action."
    end
  end

  def set_current_estimate
    @current_estimate = @estimation_session.effort_estimates
      .joins(:category)
      .where(effort: @estimation_session.current_effort)
      .where.not(status: [ :pending, :finalized ])
      .first

    if @current_estimate.nil?
      redirect_to project_estimation_session_path(@project), alert: "No active estimate found."
    end
  end

  def broadcast_parameter_selection_update(estimate)
    Turbo::StreamsChannel.broadcast_replace_to(
      @estimation_session,
      target: "#{estimate.category.title.parameterize}-steps",
      html: ApplicationController.render(
        EstimationSessionUi::EstimateStepsComponent.new(estimate: estimate),
        layout: false
      )
    )

    Turbo::StreamsChannel.broadcast_update_to(
      [ @estimation_session, :is_facilitator ],
      target: "#{estimate.category.title.parameterize}-parameter-selector",
      html: ""
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      @estimation_session,
      target: "#{estimate.category.title.parameterize}-parameter-display",
      html: ApplicationController.render(
        EstimationSessionUi::ParameterDisplayComponent.new(estimate: estimate),
        layout: false
      )
    )
  end
end
