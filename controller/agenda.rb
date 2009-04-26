class AgendaController < Controller
  helper :user, :aspect, :utils
  
  def update_agenda
    redirect :/ unless user.respond_to?(:agenda)
      
    agenda = user.agenda
    begin
      agenda.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_agenda), e)
    end
    
    if agenda.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(agenda.errors, 'agenda')
      redirect R(SettingsController, :agenda)
    end
  end
  
  def update_event
    Ramaze::Log.warn "ID: " + request[:event_id]
    event = user.agenda.event(request[:event_id])

    redirect :/ if event.nil?

    event.prepare_update(request, user)

    if event.valid?
      begin
        event.save
      rescue Sequel::DatabaseError => e
        oops(Rs(:update_event), e)
      end
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect SettingsController.r(:event, event.id)
    end
    redirect ProfileController.r(:view)
  end
  
  def create_event
    event = Event.prepare_insert(request, user)
    if event.valid?
      begin
        user.agenda.add_event(event)
      rescue Sequel::DatabaseError => e
        oops(Rs(:create_event), e)
      end
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect R(SettingsController, :event)
    end
    redirect R(ProfileController, :view)
  end
  
  before([:update_agenda, :create_event, :update_event]) {redirect_referer unless request.post? && logged_in?}
end