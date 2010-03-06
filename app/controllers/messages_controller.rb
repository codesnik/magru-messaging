class MessagesController < ApplicationController

  MESSAGES_PER_PAGE = 5
  THREADS_PER_PAGE = 5

  respond_to :html, :json

  before_filter :require_auth

  # не работает в текущей версии гема.
  #self.per_page = 5

  # GET /messages
  # GET /messages.json
  def index
    @threads = Message.threads.with_user(current_user).ordered_by_activity \
      .paginate(:page => params[:page], :per_page => THREADS_PER_PAGE)

    respond_with @messages
  end

  # GET /messages/1
  # GET /messages/1.json -> выдаст весь тред. возможно надо менять
  def show
    @thread = Message.find(params[:id]).thread

    forbid! unless allowed_to_view?(@thread)

    @messages = @thread.thread_messages \
      .paginate(:page => params[:page], :per_page => MESSAGES_PER_PAGE)

    @thread.read!(current_user)

    respond_with @messages
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.written_by(current_user).new

    respond_with @message
  end

  # GET /messages/1/reply
  def reply
    @thread = Message.find(params[:id]).thread

    forbid! unless allowed_to_view?(@thread)

    @message = @thread.new_reply(current_user)
    render :new
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])

    forbid! unless allowed_to_view?(@message)
    forbid! 'изменение запрещено: сообщение уже прочитано' unless allowed_to_change?(@message)
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.written_by(current_user).new(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to(@message, :notice => 'сообщение отправлено') }
        format.json { render :json => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.json { render :json => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    forbid! unless allowed_to_view?(@message)
    forbid! 'изменение запрещено: сообщение уже прочитано' unless allowed_to_change?(@message)

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to(@message, :notice => 'сообщение изменено') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])

    forbid! unless allowed_to_change?(@message)

    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url, :notice => 'сообщение удалено') }
      format.json { head :ok }
    end
  end

  protected

  def allowed_to_view?(message)
    [message.recipient, message.sender].include?(current_user)
  end

  def allowed_to_change?(message)
    current_user == message.sender && message.unread?
  end
  helper_method :allowed_to_view?, :allowed_to_change?

  module Messaging
    class NotAllowed < StandardError
    end
  end

  def forbid! message="действие запрещено"
    raise Messaging::NotAllowed, message
  end

  rescue_from Messaging::NotAllowed do |e|
    respond_to do |format|
      format.html { redirect_to messages_url, :alert => e.message }
      format.json { head :forbidden }
    end
  end

end
