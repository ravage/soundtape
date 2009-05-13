cat = DB[:categories]
pt = DB['SELECT id FROM languages WHERE abbr = ?', 'PT'].first
en = DB['SELECT id FROM languages WHERE abbr = ?', 'EN'].first

if cat.count == 0
  cat.insert( :language_id => pt[:id], :description => 'Rock', :ref_id => 1)
  cat.insert( :language_id => pt[:id], :description => 'Classical', :ref_id => 2)
  
  cat.insert( :language_id => en[:id], :description => 'Rock', :ref_id => 1)
  cat.insert( :language_id => en[:id], :description => 'Clássica', :ref_id => 2)
end
