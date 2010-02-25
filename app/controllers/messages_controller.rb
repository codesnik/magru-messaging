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
    @messages = Message.grouped_by_thread.with_user(current_user) \
      .paginate(:page => params[:page], :per_page => THREADS_PER_PAGE)

    respond_with @messages
  end

  # GET /messages/1
  # GET /messages/1.json -> выдаст весь тред. возможно надо менять
  def show
    @thread = Message.find(params[:id]).thread
    unless allowed_to_view?(@thread)
      forbid_action
      return
    end

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

    unless allowed_to_view?(@thread)
      forbid_action
      return
    end

    @message = @thread.new_reply(current_user)
    render :new
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])

    unless allowed_to_change?(@message)
      forbid_action
      return
    end
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

    # TODO сделать отдельное сообщение на случай
    # если сообщение прочитали после начала редактирования
    unless allowed_to_change?(@message)
      forbid_action
      return
    end

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

    unless allowed_to_change?(@message)
      forbid_action
      return
    end

    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url, :notice => 'сообщение удалено') }
      format.json { head :ok }
    end
  end

  protected

  # TODO сделать before filter, или что-то в духе
  def allowed_to_view?(message)
    [message.recipient, message.sender].include?(current_user)
  end

  def allowed_to_change?(message)
    current_user == message.sender && message.unread?
  end
  helper_method :allowed_to_view?, :allowed_to_change?

end
