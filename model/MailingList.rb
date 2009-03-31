class MailingList < Sequel::Model(:mailing_lists)
  has_many  :mailing_list_messages
end