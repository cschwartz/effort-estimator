class SessionParticipantsController < ApplicationController
  before_action :set_project
  before_action :set_estimation_session

  def create
    @participant = @estimation_session.session_participants.build(
      user: current_user,
      joined_at: Time.current,
      status: :active
    )

    if @participant.save
      redirect_to project_estimation_session_path(@project), notice: "Joined estimation session."
    else
      redirect_to project_path(@project), alert: @participant.errors.full_messages.join(", ")
    end
  end

  def destroy
    @participant = @estimation_session.session_participants.find(params[:id])

    unless @participant.user == current_user
      redirect_to project_estimation_session_path(@project), alert: "You can only leave your own session."
      return
    end

    @participant.update(status: :left)
    redirect_to project_path(@project), notice: "You have left the estimation session."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_estimation_session
    @estimation_session = @project.estimation_session
    redirect_to project_path(@project), alert: "No active estimation session" if @estimation_session.nil?
  end

  def session_participant_params
    params.fetch(:session_participant, {}).permit
  end
end
