class Message
  include DataMapper::Resource
  extend ActiveModel::Translation

  property :id, Serial
  property :subject, String
  property :body, Text, :required => true
  property :unread, Boolean, :default => true, :required => true, :lazy => false
  timestamps :at

  belongs_to :parent, "Message", :required => false
  belongs_to :sender, "User"
  belongs_to :recipient, "User"
  has n, :messages, :child_key => :parent_id # :dependent => :delete_all ?

  # scopes
  class << self
    def ordered_by_creation; all(:order => :created_at.desc) end
    def threads; all(:parent => nil) end
    def unread; all(:unread => true) end
    def with_user(user)
      # all(:conditions => ["recipient_id = ? or sender_id = ?", user.id, user.id])
      all(:recipient => user) + all(:sender => user)
    end
    def written_by(user); all(:sender => user) end
    def received_by(user); all(:recipient => user) end
    def unread_by(user); unread.received_by(user) end
    def ordered_by_activity; all(:order => :updated_at.desc) end
  end

  def thread_starter?; !parent end
  def reply?; !thread_starter? end

  def thread; parent || self end

  def thread_messages
    ## TODO try to get this via association
    #Message.all(:id => thread.id) + Message.all(:parent => thread)
    Message.all(:conditions => ["id = ? or parent_id = ?", thread.id, thread.id])
  end

  def thread_messages_count
    thread.messages.count + 1
  end

  def new_reply(author)
    msg = thread.messages.new :sender => author
    # можно писать в свой же тред
    msg.recipient = (thread.sender == author) ? thread.recipient : thread.sender
    msg
  end

  delegate :subject, :to => :thread, :prefix => :thread

  def unread_by?(reader)
    unread? && reader != sender
  end

  def unread_count_for(reader)
    thread_messages.unread_by(reader).count
  end

  def thread_unread_by?(reader)
    unread_count_for(reader) != 0
  end

  def first_unread_or_last_read_for(reader)
    thread_messages.unread_by(reader).first(:order => :created_at.asc) ||
      thread_messages.first(:order => :created_at.desc)
  end

  def read!(reader)
    thread_messages.unread_by(reader).update! :unread => false
  end

  after :create do
    # для сортировки в инбоксе
    parent && parent.touch
  end
end
