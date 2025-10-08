# frozen_string_literal: true

class IconComponent < ViewComponent::Base
  ICONS = {
    # Alert icons
    success: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z",
    error: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z",
    info: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
    close: "M6 18L18 6M6 6l12 12",
    # Tree icons
    chevron_down: "m19.5 8.25-7.5 7.5-7.5-7.5",
    chevron_right: "m8.25 4.5 7.5 7.5-7.5 7.5",
    arrows_up_down: "M3 7.5 7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5",
    hashtag: "M5.25 8.25h15m-16.5 7.5h15m-1.8-13.5-3.9 19.5m-2.1-19.5-3.9 19.5"
  }.freeze

  SIZES = {
    xs: "h-3 w-3",
    sm: "h-4 w-4",
    md: "h-6 w-6",
    lg: "h-8 w-8",
    xl: "h-12 w-12"
  }.freeze

  def initialize(name:, size: :md, css_class: nil, **options)
    @name = name.to_sym
    @size = size
    @css_class = css_class
    @options = options
  end

  def path
    ICONS[@name] || raise(ArgumentError, "Unknown icon: #{@name}")
  end

  def size_class
    SIZES[@size] || SIZES[:md]
  end

  def classes
    classes = [ size_class ]
    classes << @css_class if @css_class
    classes.join(" ")
  end

  def svg_options
    {
      xmlns: "http://www.w3.org/2000/svg",
      class: classes,
      fill: @options[:fill] || "none",
      viewBox: "0 0 24 24",
      stroke: @options[:stroke] || "currentColor"
    }.merge(@options.except(:fill, :stroke))
  end

  def path_options
    {
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "stroke-width": "2",
      d: path
    }
  end
end
