class EstimationOptionsController < ApplicationController
  before_action :set_estimation_option, only: [ :show, :edit, :update, :destroy ]

  def index
    @estimation_options = EstimationOption.all.order(:title)
  end

  def show
  end

  def new
    @estimation_option = EstimationOption.new
  end

  def edit
  end

  def create
    @estimation_option = EstimationOption.new(estimation_option_params)

    if @estimation_option.save
      respond_to do |format|
        format.html { redirect_to estimation_options_path, notice: "Estimation option was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Estimation option was successfully created." }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @estimation_option.update(estimation_option_params)
      respond_to do |format|
        format.html { redirect_to estimation_options_path, notice: "Estimation option was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Estimation option was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @estimation_option.destroy
    respond_to do |format|
      format.html { redirect_to estimation_options_path, notice: "Estimation option was successfully deleted." }
      format.turbo_stream { flash.now[:notice] = "Estimation option was successfully deleted." }
    end
  end

  private

  def set_estimation_option
    @estimation_option = EstimationOption.find(params.expect(:id))
  end

  def estimation_option_params
    params
      .require(:estimation_option)
      .permit(
        :title,
        estimation_option_values_attributes: [ :id, :value, :_destroy ]
      )
  end
end
