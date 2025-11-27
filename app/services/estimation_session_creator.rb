require "ostruct"

class EstimationSessionCreator
  def self.call(project:, facilitator:, estimation_option:)
    new(project: project, facilitator: facilitator, estimation_option: estimation_option).call
  end

  def initialize(project:, facilitator:, estimation_option:)
    @project = project
    @facilitator = facilitator
    @estimation_option = estimation_option
    @errors = []
  end

  def call
    ActiveRecord::Base.transaction do
      create_session
      find_first_leaf_effort
      create_facilitator_participant
      create_effort_estimates
      activate_first_category

      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end

    OpenStruct.new(
      success: @errors.empty?,
      session: @session,
      errors: @errors
    )
  end

  private

  def create_session
    @session = EstimationSession.new(
      project: @project,
      facilitator: @facilitator,
      estimation_option: @estimation_option,
      status: :active
    )

    unless @session.save
      @errors.concat(@session.errors.full_messages)
    end
  end

  def find_first_leaf_effort
    return if @errors.any?

    leaves = @project.effort_leaves

    if leaves.empty?
      @errors << "Project must have at least one leaf effort to estimate"
      return
    end

    @session.current_effort = leaves.first
    unless @session.save
      @errors.concat(@session.errors.full_messages)
    end
  end

  def create_facilitator_participant
    return if @errors.any?

    participant = @session.session_participants.build(
      user: @facilitator,
      joined_at: Time.current,
      status: :active
    )

    unless participant.save
      @errors.concat(participant.errors.full_messages)
    end
  end

  def create_effort_estimates
    return if @errors.any?

    all_leaves = @project.effort_leaves


    all_leaves.each do |effort|
      @project.categories.each do |category|
        estimate = @session.effort_estimates.build(
          effort: effort,
          category: category,
          status: :pending
        )

        unless estimate.save
          @errors.concat(estimate.errors.full_messages)
        end
      end
    end
  end

  def activate_first_category
    return if @errors.any?
    return unless @session.current_effort

    # Find first category for current effort and activate it
    first_estimate = @session.effort_estimates
      .where(effort: @session.current_effort)
      .order(:category_id)
      .first

    return unless first_estimate

    # Set initial state based on category type
    if first_estimate.category.scaled?
      first_estimate.status = :parameter_selection
    else
      first_estimate.status = :voting
    end

    unless first_estimate.save
      @errors.concat(first_estimate.errors.full_messages)
    end
  end
end
