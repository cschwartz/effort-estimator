class Authentication::CardComponent < ViewComponent::Base
  renders_many :links

  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = subtitle
  end
end
