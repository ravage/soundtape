class AgendaController < Controller
  helper :user, :aspect, :utils
  
  def event(user_id = nil, event_id = nil)
    @title = _('Event')
  end
  
  def update_agenda
    @title = _('Update Agenda')
    redirect :/ unless user.respond_to?(:agenda)
      
    agenda = user.agenda
    begin
      agenda.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_agenda), e)
    end
    
    if agenda.valid?
      redirect SettingsController.r(:agenda)
    else
      prepare_flash(agenda.errors, 'agenda')
      redirect_referer
    end
  end
  
  def update_event
    @title = _('Update Event')
    event = user.agenda.event(request[:event_id])

    redirect :/ if event.nil?

    event.prepare(request, user)

    if event.valid?
      begin
        event.save_changes
      rescue Sequel::DatabaseError => e
        oops(r(:update_event), e)
      end
      redirect SettingsController.r(:agenda)
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect_referer
    end
  end
  
  def create_event
    @title = _('Create Event')
    event = Event.new
    event.prepare(request, user)
    if event.valid?
      begin
        user.agenda.add_event(event)
      rescue Sequel::DatabaseError => e
        oops(r(:create_event), e)
      end
      redirect SettingsController.r(:agenda)
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect_referer
    end
  end
  
  def delete_event(event_id)
    @title = _('Delete Event')
    redirect SettingsController.r(:agenda) if event_id.nil?
    event = user.agenda.event(event_id)
    redirect SettingsController.r(:agenda) if event.nil?
    event.sane_delete
    redirect SettingsController.r(:agenda)
  end
  
  before(:update_agenda, :create_event, :update_event) {redirect_referer unless request.post? && logged_in?}
end