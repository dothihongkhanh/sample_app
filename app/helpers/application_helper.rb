module ApplicationHelper
  def full_title(page_title = "")
    base_title = "Ruby on Rails Tutorial Sample App"
    page_title.blank? ? base_title : page_title + " | " + base_title
  end

  def error_messages_for(object, field)
    return if object.errors[field].blank?

    content_tag(:div, class: "invalid-feedback") do
      object.errors.full_messages_for(field).join("<br>").html_safe
    end
  end

  def field_error_class(object, field)
    object.errors[field].any? ? "is-invalid" : ""
  end
end
