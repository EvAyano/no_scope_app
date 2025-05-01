require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "不明なパスのとき" do
    it "404のページが表示されること" do
      get "/unknown_path"
      expect(response).to have_http_status(:not_found)
    end
  end
end
