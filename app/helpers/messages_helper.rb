module MessagesHelper
  def message_recipient_options message
    options_from_collection_for_select( User.all - [current_user], :id, :name, message.recipient_id)
  end

  def message_from_to message
    h(message.sender.try(:name)) + ' &rArr; '.html_safe + h(message.recipient.try(:name))
  end

  def message_unread? message
    (current_user != message.sender) && message.unread?
  end

  def message_unread_mark message
    if message_unread?(message)
      '(NEW!!)'
    end
  end

  def message_timestamp message
    time_ago_in_words message.created_at
  end
end
