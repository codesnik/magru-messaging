class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  # заглушка для эмуляции авторизованности
  def current_user
    @current_user ||= if session[:user_id]
      User.find(session[:user_id])
    end
  end
  helper_method :current_user

  def current_user=(user)
    @current_user = user
    session[:user_id] = user ? user.id : nil
  end

  # filters
  def require_auth
    unless current_user
      redirect_to users_path, :alert => 'требуется аутентификация'
    end
  end

  def forbid_action
    redirect_to :back, :alert => "действие запрещено"
  end

end
