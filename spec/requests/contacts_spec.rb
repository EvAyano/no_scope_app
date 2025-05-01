require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  describe "GET /contacts/new" do
    it "問い合わせフォームが表示されること" do
      get new_contact_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("お問い合わせ前にご確認ください")
    end
  end

  describe "POST/contacts" do
    context "パラメータが有効な場合" do
      let(:valid_params) do
        {contact: {name: "名無しのテストさん",email: 'test@noscope.com',message: "テストお問い合わせ"}}
      end

      it "完了ページにリダイレクトすること" do
        #スタブContactsControllerのsend_to_google_formをrecieveしてもnilを返す
        allow_any_instance_of(ContactsController).to receive(:send_to_google_form)

        post contacts_path, params: valid_params
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(completed_contacts_path)
      end
    end

    context "パラメータが無効な場合" do
      let(:invalid_params) do
        {contact: {name: "",email: "test@noscope.com",message: "テスト内容"}}
      end

      it "エラーが表示されること" do
        post contacts_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("エラーが発生しました")
      end
    end
  end

  describe "GET/contacts/completed" do
    it "完了画面が表示されること" do
      get completed_contacts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("お問い合わせが完了しました！")
    end
  end
end
