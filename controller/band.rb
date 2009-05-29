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
      flash[:message] = _('There was an error adding the element. Please make sure you mentioned which instruments your element plays')
      pp flash
    end 
    redirect_referer
  end

  before(:create__element) { redirect_referer unless logged_in? && request.post?}
end