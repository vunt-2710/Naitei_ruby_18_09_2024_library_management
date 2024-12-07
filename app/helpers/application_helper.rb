module ApplicationHelper
  def full_title page_title
    base_title = t "app_name"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def search_type_options
    [
      [t("header.search.dropdown.all"), "all"],
      [t("header.search.dropdown.name"), "name"],
      [t("header.search.dropdown.author"), "author"],
      [t("header.search.dropdown.publisher"), "publisher"]
    ]
  end
end
