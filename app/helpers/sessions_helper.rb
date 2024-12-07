module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def current_user
    return unless user_id = session[:user_id]

    @current_user ||= User.find_by id: user_id
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    reset_session
    @current_user = nil
  end
end
