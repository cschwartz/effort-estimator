module Display
  class BadgeComponent < ViewComponent::Base
    def initialize(label:, variant: :default, size: :sm, css_class: nil)
      @label = label
      @variant = variant
      @size = size
      @css_class = css_class
    end

    attr_reader :label, :variant, :size, :css_class

    def badge_classes
      classes = [ "badge" ]
      classes << "badge-#{size}" if size
      classes << variant_class
      classes << css_class if css_class
      classes.join(" ")
    end

    private

    def variant_class
      case variant
      when :primary
        "badge-primary"
      when :success
        "badge-success"
      when :warning
        "badge-warning"
      when :info
        "badge-info"
      when :error
        "badge-error"
      when :ghost
        "badge-ghost"
      when :outline
        "badge-outline"
      else
        ""
      end
    end
  end
end
