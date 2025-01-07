class Api::V1::BooksController < ApplicationController
  include BooksHelper

  load_resource # skip authorization to test API
  skip_before_action :verify_authenticity_token # skip csrf to test API
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    @q = Book.ransack(search_params, auth_object: user_role)
    @q.sorts = "name asc" if @q.sorts.empty?
    @pagy, @books = pagy @q.result.includes(:author, cover_attachment: :blob),
                         limit: Settings.default_pagination
    render json: @books, each_serializer: BookIndexSerializer
  end

  def show
    @pagy, @comments = pagy Comment.includes(:user).by_book(@book.id),
                            limit: Settings.default_pagination
    render json: BookShowSerializer.new(@book, comments: @comments)
                                   .serializable_hash
  end

  def create
    book = Book.new(book_params)
    if book.save
      render json: {message: t("success.book_created"), book:},
             status: :created
    else
      render json: {errors: book.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: {message: t("success.book_updated")}, status: :ok
    else
      render json: {errors: @book.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    render json: {message: t("success.book_deleted")}, status: :ok
  end

  private

  def book_params
    params.require(:book).permit(Book::PERMITTED_PARAMS)
  end

  def search_params
    update_in_stock_option if contain_in_stock_option?
    apply_or_query
  end

  def update_in_stock_option
    in_stock_option = "in_stock_#{params[:q][:amount_operator]}".to_sym
    params[:q][in_stock_option] = params[:q][:in_stock]
  end

  def apply_or_query
    is_or_query? ? params[:q].try(:merge, m: "or") : params[:q]
  end

  def contain_in_stock_option?
    params.dig(:q, :amount_operator) && params.dig(:q, :in_stock)
  end

  def handle_record_not_found
    render json: {error: t("error.book_not_found")}, status: :not_found
  end
end
