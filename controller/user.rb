class UserController < Controller
  helper :utils
  

  def register
    if request.post?

       user = User.prepare(request.params)

       if user.valid?
         begin
           user.save
         rescue Sequel::Error => e
           oops('user/register', e)
           flash[:exception] = true
           redirect '/oops'
         end
         flash[:success] = _('successfully created account')
       else
         flash[:email], flash[:real_name] = request[:email], request[:real_name]
       end
     end
  end
  
  private
  
  def send_activation_mail
  end
end