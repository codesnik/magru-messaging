module MessagesHelper
  def message_recipient_options message
    options_from_collection_for_select( User.all - [current_user], :id, :name, message.recipient_id)
  end

  def message_from_to message
    h(message.sender.try(:name)) + ' &rArr; '.html_safe + h(message.recipient.try(:name))
  end

  def message_unread_mark message
    if message.unread_by?(current_user)
      content_tag :strong, 'NEW'
    end
  end

  def thread_unread_counter message
    count = message.unread_count(current_user)
    if count > 0
      content_tag :strong, "#{count} NEW"
    end
  end

  def message_timestamp message
    content_tag :span, (time_ago_in_words(message.created_at) + ' назад'),
      :title => l(message.created_at)
  end

  def thread_excerpt message
    content_tag :div, :class => "excerpt" do
      concat content_tag(:strong, link_to(message.thread_subject, message))
      concat raw(" &mdash; ")
      concat link_to(message.body, message)
    end
  end
end
