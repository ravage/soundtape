class MailingList < Sequel::Model
  has_many  :mailing_list_messages
end