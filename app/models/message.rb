class Message < ActiveRecord::Base
  belongs_to :parent, :class_name => "Message"
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
end
