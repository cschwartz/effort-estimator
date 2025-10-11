require 'rails_helper'

RSpec.describe EstimationOption, type: :model do
  describe 'associations' do
    it 'has many estimation_option_values' do
      option = create(:estimation_option)
      value1 = create(:estimation_option_value, estimation_option: option, value: 1)
      value2 = create(:estimation_option_value, estimation_option: option, value: 2)

      expect(option.estimation_option_values).to include(value1, value2)
    end

    it 'destroys associated values when destroyed' do
      option = create(:estimation_option)
      value = create(:estimation_option_value, estimation_option: option)

      expect { option.destroy }.to change(EstimationOptionValue, :count).by(-1)
    end
  end

  describe 'validations' do
    it 'requires a title' do
      option = EstimationOption.new(title: nil)
      expect(option).not_to be_valid
      expect(option.errors[:title]).to include("can't be blank")
    end

    it 'requires a unique title' do
      create(:estimation_option, title: "Fibonacci")
      option = EstimationOption.new(title: "Fibonacci")

      expect(option).not_to be_valid
      expect(option.errors[:title]).to include("has already been taken")
    end

    it 'allows different titles' do
      create(:estimation_option, title: "Fibonacci")
      option = EstimationOption.new(title: "T-Shirt Sizes")

      expect(option).to be_valid
    end
  end
end
