class EventController < Controller
  def create(user_id)
    redirect :/ unless logged_in? || !request.post?
    redirect R(ProfileController, :edit, user.id) unless user.id = user_id
    redirect R(ProfileController, :edit, user.id) unless user.agendas.first.id == request[:agend_id]
  end
end