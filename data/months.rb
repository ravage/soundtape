month = DB[:months]
pt = DB['SELECT id FROM languages WHERE abbr = ?', 'PT'].first
en = DB['SELECT id FROM languages WHERE abbr = ?', 'EN'].first

if month.count == 0
  month.insert( :language_id => pt[:id], :month => 'Janeiro', :ref_id => 1)
  month.insert( :language_id => pt[:id], :month => 'Fevereiro', :ref_id => 2)
  month.insert( :language_id => pt[:id], :month => 'Março', :ref_id => 3)
  month.insert( :language_id => pt[:id], :month => 'Abril', :ref_id => 4)
  month.insert( :language_id => pt[:id], :month => 'Maio', :ref_id => 5)
  month.insert( :language_id => pt[:id], :month => 'Junho', :ref_id => 6)
  month.insert( :language_id => pt[:id], :month => 'Julho', :ref_id => 7)
  month.insert( :language_id => pt[:id], :month => 'Agosto', :ref_id => 8)
  month.insert( :language_id => pt[:id], :month => 'Setembro', :ref_id => 9)
  month.insert( :language_id => pt[:id], :month => 'Outubro', :ref_id => 10)
  month.insert( :language_id => pt[:id], :month => 'Novembro', :ref_id => 12)
  month.insert( :language_id => pt[:id], :month => 'Dezembro', :ref_id => 12)
  
  month.insert( :language_id => en[:id], :month => 'January', :ref_id => 1)
  month.insert( :language_id => en[:id], :month => 'February', :ref_id => 2)
  month.insert( :language_id => en[:id], :month => 'March', :ref_id => 3)
  month.insert( :language_id => en[:id], :month => 'April', :ref_id => 4)
  month.insert( :language_id => en[:id], :month => 'May', :ref_id => 5)
  month.insert( :language_id => en[:id], :month => 'June', :ref_id => 6)
  month.insert( :language_id => en[:id], :month => 'July', :ref_id => 7)
  month.insert( :language_id => en[:id], :month => 'August', :ref_id => 8)
  month.insert( :language_id => en[:id], :month => 'September', :ref_id => 9)
  month.insert( :language_id => en[:id], :month => 'October', :ref_id => 10)
  month.insert( :language_id => en[:id], :month => 'November', :ref_id => 11)
  month.insert( :language_id => en[:id], :month => 'December', :ref_id => 12)
end
