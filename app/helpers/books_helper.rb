module BooksHelper
  def book_cover book
    book.cover.presence || Settings.book.default_cover
  end

  def get_index counter
    (@pagy.page - 1) * @pagy.limit + counter + 1
  end
end
