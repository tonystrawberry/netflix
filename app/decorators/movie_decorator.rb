class MovieDecorator < Draper::Decorator
  delegate_all

  def audience_type
    case object.audience_type.to_sym
    when :all
      "ALL"
    when :kids_7
      "7+"
    when :kids_12
      "12+"
    when :teens_13
      "13+"
    when :adults_16
      "16+"
    when :adults_18
      "18+"
    end
  end

  def media_type
    case object.media_type.to_sym
    when :movie
      "Movie"
    when :series
      "Series"
    end
  end

  def release_year
    object.released_on.year
  end

  def publishing_status
    case object.publishing_status.to_sym
    when :draft
      h.content_tag(:span, "Draft", class: "rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-700 ring-1 ring-inset ring-gray-600/20")
    when :published
      h.content_tag(:span, "Published", class: "rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20")
    end
  end

  def published_at
    object.published_at&.strftime("%B %d, %Y")
  end
end
