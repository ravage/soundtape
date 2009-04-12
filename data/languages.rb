lang = DB[:languages]

if lang.count == 0
  lang.insert( :abbr => 'PT', :language => 'Português')
  lang.insert( :abbr => 'EN', :language => 'English')
end
