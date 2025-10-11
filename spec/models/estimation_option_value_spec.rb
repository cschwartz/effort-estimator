require 'rails_helper'

RSpec.describe EstimationOptionValue, type: :model do
  describe 'associations' do
    it 'belongs to estimation_option' do
      option = create(:estimation_option)
      value = create(:estimation_option_value, estimation_option: option)

      expect(value.estimation_option).to eq(option)
    end
  end

  describe 'validations' do
    let(:option) { create(:estimation_option) }

    it 'requires a value' do
      value = EstimationOptionValue.new(estimation_option: option, value: nil)
      expect(value).not_to be_valid
      expect(value.errors[:value]).to include("can't be blank")
    end

    it 'requires value to be greater than 0' do
      value = EstimationOptionValue.new(estimation_option: option, value: 0)
      expect(value).not_to be_valid
      expect(value.errors[:value]).to include("must be greater than 0")
    end

    it 'allows positive integers' do
      value = EstimationOptionValue.new(estimation_option: option, value: 5)
      expect(value).to be_valid
    end

    it 'requires value to be unique within the same estimation option' do
      create(:estimation_option_value, estimation_option: option, value: 5)
      duplicate_value = EstimationOptionValue.new(estimation_option: option, value: 5)

      expect(duplicate_value).not_to be_valid
      expect(duplicate_value.errors[:value]).to include("has already been taken")
    end

    it 'allows same value in different estimation options' do
      option2 = create(:estimation_option)
      create(:estimation_option_value, estimation_option: option, value: 5)
      value_in_different_option = EstimationOptionValue.new(estimation_option: option2, value: 5)

      expect(value_in_different_option).to be_valid
    end
  end
end
