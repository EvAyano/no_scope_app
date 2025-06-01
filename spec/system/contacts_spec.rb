require 'rails_helper'

RSpec.describe "Contact Form", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "お問い合わせフォーム" do
    before do
      visit new_contact_path
    end

    it "正しく入力して送信すれば完了ページへ遷移する" do
      fill_in "contact_name", with: "テストユーザー"
      fill_in "contact_email", with: "test@noscope.com"
      fill_in "contact_message", with: "テストのお問い合わせ内容"
      

      click_button "送信"

      expect(page).to have_current_path(completed_contacts_path, wait: 5)
      expect(page).to have_content("お問い合わせが完了しました！")
    end

    context "バリデーションエラー" do
      it "ニックネームが空欄だとエラーが出る" do
        fill_in "contact_message", with: "テストのお問い合わせ内容"
        click_button "送信"

        expect(page).to have_selector(".error-message-header", text: "エラーが発生しました。", wait: 5)
        expect(page).to have_content("名前を入力してください")
      end

      it "お問い合わせ内容が空欄だとエラーが出る" do
        fill_in "contact_name", with: "テストユーザー"
        click_button "送信"

        expect(page).to have_content("お問い合わせ内容を入力してください")
      end

      it "メールアドレスが不正だとエラーが出る" do
        fill_in "contact_name", with: "テストユーザー"
        fill_in "contact_email", with: "fusei_email"
        fill_in "contact_message", with: "テストのお問い合わせ内容"

        click_button "送信"

        expect(page).to have_content("メールアドレスは不正な値です")
      end

      it "ニックネームが10文字以上だとエラーが出る" do
        fill_in "contact_name", with: "これは11文字以上です"
        fill_in "contact_message", with: "テストのお問い合わせ内容"
        click_button "送信"

        expect(page).to have_content("名前は10文字以内で入力してください")
      end

      it "お問い合わせ内容が1000字だとエラーが出る" do
        fill_in "contact_name", with: "テストユーザー"
        fill_in "contact_message", with: "あ" * 1001
        click_button "送信"

        expect(page).to have_content("お問い合わせ内容は1000文字以内で入力してください")
      end
    end
  end
end
