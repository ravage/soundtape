class AgendaController < Controller
  helper :user, :aspect, :utils
  
  def update_agenda
    redirect :/ unless user.respond_to?(:agenda)
      
    agenda = user.agenda
    begin
      agenda.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_agenda), e)
    end
    
    if agenda.valid?
      redirect ProfileController.r(:view, user.alias)
    else
      prepare_flash(agenda.errors, 'agenda')
      redirect SettingsController.r(:agenda)
    end
  end
  
  def update_event
    Ramaze::Log.warn "ID: " + request[:event_id]
    event = user.agenda.event(request[:event_id])

    redirect :/ if event.nil?

    event.prepare(request, user)

    if event.valid?
      begin
        event.save_changes
      rescue Sequel::DatabaseError => e
        oops(r(:update_event), e)
      end
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect SettingsController.r(:event, event.id_)
    end
    redirect ProfileController.r(:view)
  end
  
  def create_event
    event = Event.prepare_insert(request, user)
    if event.valid?
      begin
        user.agenda.add_event(event)
      rescue Sequel::DatabaseError => e
        oops(r(:create_event), e)
      end
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect r(SettingsController, :event)
    end
    redirect r(ProfileController, :view)
  end
  
  def delete_event(event_id = nil)
    redirect SettingsController.r(:agenda) if event_id.nil?
    event = user.agenda.event(event_id)
    redirect SettingsController.r(:agenda) if event.nil?
    event.sane_delete
    redirect SettingsController.r(:agenda)
  end
  
  before(:update_agenda, :create_event, :update_event) {redirect_referer unless request.post? && logged_in?}
end