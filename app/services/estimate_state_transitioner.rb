# frozen_string_literal: true

class EstimateStateTransitioner
  class << self
    def select_parameter(estimate:, parameter:)
      new(estimate).select_parameter(parameter)
    end

    def reveal(estimate:)
      new(estimate).reveal
    end

    def finalize(estimate:, estimation_option_value:)
      new(estimate).finalize(estimation_option_value)
    end

    def restart(estimate:)
      new(estimate).restart
    end
  end

  def initialize(estimate)
    @estimate = estimate
  end

  def select_parameter(parameter)
    return error("Can only select parameter during parameter_selection state") unless @estimate.parameter_selection?
    return error("Parameter is required") if parameter.nil?
    return error("Parameter must belong to the same project") unless parameter.project_id == @estimate.effort.project_id

    if @estimate.update(parameter: parameter, status: :voting)
      success
    else
      error(@estimate.errors.full_messages.join(", "))
    end
  end

  def reveal
    return error("Can only reveal during voting state") unless @estimate.voting?
    return error("Cannot reveal before votes are cast") if @estimate.estimation_votes.empty?

    if @estimate.update(status: :revealed)
      success
    else
      error(@estimate.errors.full_messages.join(", "))
    end
  end

  def finalize(estimation_option_value)
    return error("Can only finalize during revealed state") unless @estimate.revealed?
    return error("Estimation option value is required") if estimation_option_value.nil?

    if @estimate.update(estimation_option_value: estimation_option_value, status: :finalized)
      success
    else
      error(@estimate.errors.full_messages.join(", "))
    end
  end

  def restart
    return error("Can only restart finalized estimates") unless @estimate.finalized?

    @estimate.transaction do
      @estimate.estimation_votes.destroy_all
      @estimate.estimation_option_value = nil

      new_status = @estimate.category.scaled? ? :parameter_selection : :voting

      if @estimate.update(status: new_status)
        success
      else
        error(@estimate.errors.full_messages.join(", "))
      end
    end
  end

  private

  def success
    { success: true, estimate: @estimate, errors: [] }
  end

  def error(message)
    { success: false, estimate: @estimate, errors: [ message ] }
  end
end
