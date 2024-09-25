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
      I18n.t("activerecord.attributes.movie.types.movie")
    when :series
      I18n.t("activerecord.attributes.movie.types.series")
    end
  end

  def release_year
    object.released_on.year
  end

  def publishing_status
    case object.publishing_status.to_sym
    when :draft
      h.content_tag(:span, I18n.t("activerecord.attributes.movie.publishing_statuses.draft"), class: "rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/20")
    when :published
      h.content_tag(:span, I18n.t("activerecord.attributes.movie.publishing_statuses.published"), class: "rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20")
    end
  end

  def published_at
    object.published_at&.strftime("%B %d, %Y")
  end
end
