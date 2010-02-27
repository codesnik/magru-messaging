class Message < ActiveRecord::Base
  belongs_to :parent, :class_name => "Message"
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  has_many :messages, :foreign_key => :parent_id

  default_scope order('created_at desc')
  scope :threads, where(:parent_id => nil)
  scope :unread, where(:unread => true)
  scope :with_user, lambda { |user|
    where(["recipient_id = ? or sender_id = ?", user.id, user.id])
  }
  scope :written_by, lambda { |user| where(:sender_id => user.id) }
  scope :received_by, lambda { |user| where(:recipient_id => user.id) }
  scope :ordered_by_activity, order('updated_at desc')

  # что-то одно должно присутствовать
  validates_presence_of :body, :if => proc {|msg| msg.subject.blank? }
  validates_presence_of :sender, :recipient

  def thread_starter?; !parent_id end
  def reply?; !thread_starter? end

  def thread; parent || self end
  def thread_id; parent_id || id end

  # TODO try to get this via association
  def thread_messages
    #thread.messages + [thread]
    Message.where(["id = ? or parent_id = ?", thread_id, thread_id])
  end

  def thread_messages_count
    thread.messages.count + 1
  end

  def new_reply(author)
    msg = thread.messages.build :sender => author
    # можно писать в свой же тред
    msg.recipient = (thread.sender == author) ? thread.recipient : thread.sender
    msg
  end

  delegate :subject, :to => :thread, :prefix => :thread

  def unread_by?(reader)
    unread? && reader != sender
  end

  def unread_count_for(reader)
    thread_messages.received_by(reader).unread.count
  end

  def thread_unread_by?(reader)
    unread_count_for(reader) != 0
  end

  def first_unread_or_last_read_for(reader)
    # last и first имеют противоположный смысл из-за default_scope
    # TODO избавиться от него?
    thread_messages.received_by(reader).unread.last || thread_messages.first
  end

  def read!(reader)
    thread_messages.received_by(reader).unread.update_all :unread => false
  end

  before_save do |message|
    message.thread.touch if message.reply?
  end

end
