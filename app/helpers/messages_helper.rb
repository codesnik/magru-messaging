module MessagesHelper
  MAX_EXCERPT_CHARS = 30
  def message_recipient_options message
    options_from_collection_for_select( User.all - [current_user], :id, :name, message.recipient_id)
  end

  def message_from_to message
    h(message.sender.name) + raw(' &rArr; ') + h(message.recipient.name)
  end

  def thread_from_to message
    message_from_to( message.first_unread_or_last_read_for(current_user) )
  end

  def message_unread_mark message
    if message.unread_by?(current_user)
      content_tag :strong, 'NEW'
    end
  end

  def thread_unread_counter thread
    total = thread.thread_messages_count
    unread = thread.unread_count_for(current_user)

    case [total, unread]
    when [total, 0]
      "(#{total})"
    when [total, total]
      "(<strong>#{unread}</strong>)"
    else
      "(<strong>#{unread}</strong>/#{total})"
    end.html_safe
  end

  def message_timestamp message
    content_tag :span, l(message.created_at, :format => :short),
      :title => (time_ago_in_words(message.created_at) + ' назад')
  end

  def thread_timestamp thread
    message_timestamp(thread.first_unread_or_last_read_for(current_user))
  end

  def thread_excerpt thread
    body_excerpt = truncate(thread.first_unread_or_last_read_for(current_user).body, MAX_EXCERPT_CHARS)
    content_tag :div, :class => "excerpt" do
      concat content_tag(:strong, link_to(thread.thread_subject, thread))
      concat raw(" &mdash; ")
      concat link_to(body_excerpt, thread)
    end
  end
end
