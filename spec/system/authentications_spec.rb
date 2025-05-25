require 'rails_helper'

RSpec.describe "User Authentication and Profile Management", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:email) { 'test@noscope.com' }
  let!(:password) { 'testcspass1125!' }
  let!(:password_confirmation) { 'testcspass1125!' }
  let!(:nickname) { 'testuser' }

  describe "新規登録" do

    context "通常の場合" do
      it "情報が揃っていれば登録できる" do
        visit new_user_registration_path

        fill_in "メールアドレス", with: email
        fill_in "user[password]", with: password
        fill_in "user[password_confirmation]", with: password_confirmation

        fill_in "ニックネーム", with: nickname

        click_button "登録"

        expect(page).to have_content(nickname)

      end
    end

    context "バリデーションエラーの表示" do
      before do
        User.create!(
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          nickname: "存在しているユーザー"
        )
      end

      it "メールアドレスが未入力だとエラーが表示される" do
        visit new_user_registration_path
    
        fill_in "user[password]", with: password
        fill_in "user[password_confirmation]", with: password_confirmation
        fill_in "ニックネーム", with: nickname
    
        click_button "登録"

        expect(page).to have_content("Eメールを入力してください。", wait: 5)

      end
    
      it "パスワード未入力だとエラーが表示される" do
        visit new_user_registration_path
    
        fill_in "メールアドレス", with: email
        fill_in "user[password_confirmation]", with: password_confirmation
        fill_in "ニックネーム", with: nickname
    
        click_button "登録"
    
        expect(page).to have_content("パスワードを入力してください")
      end
    
      it "確認用のパスワード未入力だとエラーが表示される" do
        visit new_user_registration_path
    
        fill_in "メールアドレス", with: email
        fill_in "user[password]", with: password
        fill_in "ニックネーム", with: nickname
    
        click_button "登録"
    
        expect(page).to have_content("パスワード（確認用）を入力してください")
      end
    
      it "ニックネーム未入力だとエラーが表示される" do
        visit new_user_registration_path
    
        fill_in "メールアドレス", with: email
        fill_in "user[password]", with: password
        fill_in "user[password_confirmation]", with: password_confirmation
    
        click_button "登録"
    
        expect(page).to have_content("ニックネームを入力してください")
      end

      
      it "すでに登録されているメールアドレスでは登録できない" do
        visit new_user_registration_path
    
        fill_in "メールアドレス", with: email
        fill_in "user[password]", with: password
        fill_in "user[password_confirmation]", with: password_confirmation
        fill_in "ニックネーム", with: nickname
    
        click_button "登録"
    
        expect(page).to have_content("Eメールはすでに存在します。")
      end
    end
    
  end

  describe "ログイン" do
    let!(:user) { User.create!(email: 'test@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser') }

    it "メールアドレスとパスワードが正しければログインできる" do
      visit new_user_session_path

      fill_in "メールアドレス", with: email
      fill_in "user[password]", with: password
      click_button "ログイン"

      expect(page).to have_content(nickname)

    end

    it "メールアドレスが未入力だとエラーが表示される" do
      visit new_user_session_path

      fill_in "user[password]", with: password
      click_button "ログイン"

      expect(page).to have_content("Eメールまたはパスワードが違います。")
    end

    it "パスワードが未入力だとエラーが表示される" do
      visit new_user_session_path

      fill_in "メールアドレス", with: email
      click_button "ログイン"

      expect(page).to have_content("Eメールまたはパスワードが違います。")
    end
  end
  
  describe "ログアウト" do
    let!(:user) { User.create!(email: 'test@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser') }

    it "ログインしている場合はログアウトできる" do
      visit new_user_session_path
    
      fill_in "メールアドレス", with: email
      fill_in "user[password]", with: password
      click_button "ログイン"
    
      expect(page).to have_content(nickname)

      find("a.nav-link.dropdown-toggle", text: nickname).click
      click_link "ログアウト"

      expect(page).to have_current_path(root_path, wait: 5)
    
    end

    it "ログインしていない場合はログインか新規登録が表示される" do
      visit root_path

      expect(page).to have_link("ログイン", href: new_user_session_path)
      expect(page).to have_link("新規アカウント作成", href: new_user_registration_path)
    end
    

  end

end
