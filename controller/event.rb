class EventController < Controller
  helper :user, :utils
  def create(user_id)
    redirect :/ unless logged_in? || !request.post?

    Ramaze::Log.warn "INSIDE"
    event = Event.prepare(request)
    if event.valid?
      begin
        agenda = user.agendas.first
        agenda.add_event(event)
      rescue Sequel::DatabaseError => e
        oops(Rs(:create), e)
      end
    else
      prepare_flash(event.errors)
      redirect R(ProfileController, :edit, user.id)
    end
  end
end