class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  # заглушка для эмуляции авторизованности
  def current_user
    @current_user ||= if session[:user_id]
      User.find(session[:user_id])
    end
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user ? user.id : nil
  end

  helper_method :current_user
end
