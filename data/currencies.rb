cur = DB[:currencies]
pt = DB['SELECT id FROM languages WHERE abbr = ?', 'PT'].first
en = DB['SELECT id FROM languages WHERE abbr = ?', 'EN'].first

if cur.count == 0
  cur.insert( :language_id => pt[:id], :currency => 'Euro', :symbol => '€', :ref_id => 1)
  cur.insert( :language_id => pt[:id], :currency => 'Dólar', :symbol => '$', :ref_id => 2)
  cur.insert( :language_id => pt[:id], :currency => 'Libra', :symbol => '£', :ref_id => 3)
  
  cur.insert( :language_id => en[:id], :currency => 'Euro', :symbol => '€', :ref_id => 1)
  cur.insert( :language_id => en[:id], :currency => 'Dollar', :symbol => '$', :ref_id => 2)
  cur.insert( :language_id => en[:id], :currency => 'Pound', :symbol => '£', :ref_id => 3)
end
