require 'ramaze/option/dsl'
require 'ramaze/option/holder'

module SoundTape
  Email     = Ramaze::Option::Holder.new
  Database  = Ramaze::Option::Holder.new
  Constant  = Ramaze::Option::Holder.new
  
  Ramaze::Option::DSL.new Email do
    o 'SMTP Server',
      :host, 'mail.git.fragmentized.net'
    
    o 'SMTP Hello Domain',
      :hello, 'git.fragmentized.net'
    
    o 'SMTP user name',
      :user, 'ravage@git.fragmentized.net'
      
    o 'SMTP password',
      :password, '0000'
    
    o 'Sender full e-mail address',
      :from, "#{_('SoundTape Staff')} <no-reply@soundtape.net>"
      
    o 'E-mail subject prefix',
      :subject_prefix, "[SoundTape]"
  end
  
  Ramaze::Option::DSL.new Database do
    o 'Database name',
      :name, 'soundtape'

    o 'Database user name',
      :login, 'root'

    o 'Database password',
      :password, 'root'

    o 'Database host',
      :host, 'localhost'
    
    o 'Database socket',
      :socket, '/Applications/MAMP/tmp/mysql/mysql.sock'
    
    o 'Database charset for the connection',
      :charset, 'utf8'
  end
  
  Ramaze::Option::DSL.new Constant do
    o 'Types of users',
      :user_types, {:band => 'Band', :user => 'User'}
  end
end
    
