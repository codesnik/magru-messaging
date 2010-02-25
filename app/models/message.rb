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

  def thread_starter?
    !parent_id
  end

  def thread
    parent || self
  end

  def full_thread
    thread.messages + [thread]
  end

  delegate :subject, :to => :thread, :prefix => :thread

end
