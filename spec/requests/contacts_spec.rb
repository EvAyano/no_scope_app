require 'rails_helper'

RSpec.describe "Contacts", type: :request do  
  describe "GET /new" do
    it "returns http success" do
      get new_contact_path
      expect(response).to have_http_status(:success)
    end
  end
end
