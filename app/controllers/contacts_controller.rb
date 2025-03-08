class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.valid?
      send_to_google_form(@contact)
      
      redirect_to completed_contacts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def completed
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end

  def send_to_google_form(contact)
    uri = URI.parse("https://docs.google.com/forms/d/e/1FAIpQLSfOcQIr3cCc8aWPSgXlrBVkrqu1lubmKURHIHPbCDQvQI3-Ow/formResponse")
  
    params = {
      "entry.431149620" => contact.name.to_s,
      "entry.143511477" => contact.email.to_s,
      "entry.1652961404" => contact.message.to_s
    }
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(params)
      http.request(request)
    end
  end
end
