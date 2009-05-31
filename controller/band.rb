class BandController < Controller
  helper :user, :utils
  def create__element
    band_element = BandElement.new
    band_element.prepare(request, user)
    if band_element.valid?
      begin
        band_element.save
        flash[:message] = _('Element added')
      rescue Sequel::DatabaseError => e
        oops(BandController.r(:create__element), e)
      end
    else
      prepare_flash(:errors => band_element.errors, :prefix => 'element')
      flash[:message] = _('There was an error adding the element. Please make sure you mentioned your element name and instruments')
      pp flash
    end 
    redirect_referer
  end
  
  def remove__element
    redirect_referer unless element = user.element(request[:element_id])
    begin
      flash[:message] = _('Element removed')
      element.delete
    rescue Sequel::DatabaseError => e
      flash[:error] = true
      flash[:message] = _('There was a problem removing the element')
      oops(r('/remove/element'), e)
    end
    redirect_referer
  end
  
  def update__element
    redirect_referer unless element = user.element(request[:element_id])
    begin
      element.update_element(request)
      flash[:message] = _('Element updated successfully')
    rescue Sequel::DatabaseError => e
      oops(r('/update/element'), e)
    end

    unless element.valid?
      prepare_flash(:errors => element.errors, :prefix => 'uelement')
      flash[:message] = _('An error was encountered while submitting your request')
      redirect_referer
    end
    redirect SettingsController.r(:elements)
  end
  
  before(:create__element, :remove_element, :update_element) { redirect_referer unless logged_in? && user.is_a?(Band) && request.post?}
end