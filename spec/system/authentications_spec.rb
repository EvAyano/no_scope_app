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

        expect(page).to have_content("Eメールを入力してください。")

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

      it "パスワードが6文字未満だとエラーが表示される" do
        visit new_user_registration_path
    
        fill_in "メールアドレス", with: email
        fill_in "user[password]", with: "1126!"
        fill_in "user[password_confirmation]", with: "1126!"
        fill_in "ニックネーム", with: nickname
    
        click_button "登録"
    
        expect(page).to have_content("パスワードは6文字以上で入力してください。")
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

      it "エラーが発生してもニックネームは保持される" do
        visit new_user_registration_path
      
        fill_in "ニックネーム", with: "testuser"
        click_button "登録"
      
        expect(page).to have_field("ニックネーム", with: "testuser")
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

      expect(page).to have_current_path(root_path)
    
    end

    it "ログインしていない場合はログインか新規登録が表示される" do
      visit root_path

      expect(page).to have_link("ログイン", href: new_user_session_path)
      expect(page).to have_link("新規アカウント作成", href: new_user_registration_path)
    end
    

  end

  describe "アカウント情報変更" do
    let!(:user) { User.create!(email: 'test@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser') }

    before do
      user_login

      find('.dropdown-toggle').click
      click_link('アカウント情報', href: edit_user_registration_path)

      expect(page).to have_current_path(edit_user_registration_path)
      expect(page).to have_content("Account info")


    end

    context "メールアドレスの変更" do
      it "メールアドレスを変更できる" do
        click_link("変更", href: edit_user_email_path)
        expect(page).to have_current_path(edit_user_email_path)

        fill_in "新しいメールアドレス", with: "new_email_address@noscope.com"
        click_button "変更する"

        expect(page).to have_content("メールアドレスの更新が完了しました！")

      end

      it "空欄のまま変更するとエラーが出る" do
        click_link("変更", href: edit_user_email_path)
        expect(page).to have_current_path(edit_user_email_path)

        fill_in "新しいメールアドレス", with: ""
        click_button "変更する"

        expect(page).to have_content("Eメールを入力してください。")

      end

      it "不正なメアドを入力するとエラーが出る" do
        click_link("変更", href: edit_user_email_path)
        expect(page).to have_current_path(edit_user_email_path)

        fill_in "新しいメールアドレス", with: "@noscope.com"
        click_button "変更する"

        expect(page).to have_content("Eメールは不正な値です。")

      end
    end

    context "パスワードの変更" do
      before do
        click_link("変更", href: edit_custom_user_password_path)
        expect(page).to have_current_path(edit_custom_user_password_path)
      end


      it "パスワードを変更できる" do
        fill_in "現在のパスワード", with: "testcspass1125!"
        fill_in "新しいパスワード", with: "testcspass1126!"
        fill_in "新しいパスワード（確認用）", with: "testcspass1126!"

        click_button "変更する"

        expect(page).to have_content("パスワードが更新されました。")

      end

      it "現在のパスワードが空欄だと変更できない" do
        fill_in "現在のパスワード", with: ""
        fill_in "新しいパスワード", with: "testcspass1126!"
        fill_in "新しいパスワード（確認用）", with: "testcspass1126!"

        click_button "変更する"

        expect(page).to have_content("現在のパスワードを入力してください。")

      end

      it "現在のパスワードが間違っていると変更できない" do
        fill_in "現在のパスワード", with: "wrongpassword"
        fill_in "新しいパスワード", with: "testcspass1126!"
        fill_in "新しいパスワード（確認用）", with: "testcspass1126!"

        click_button "変更する"

        expect(page).to have_content("現在のパスワードは不正な値です。")

      end

      it "新しいパスワードが空欄だと変更できない" do

        fill_in "現在のパスワード", with: "testcspass1125!"
        fill_in "新しいパスワード", with: ""
        fill_in "新しいパスワード（確認用）", with: "testcspass1126!"

        click_button "変更する"

        expect(page).to have_content("パスワードを入力してください。")

      end

      it "新しいパスワード(確認用)が空欄だと変更できない" do
        fill_in "現在のパスワード", with: "testcspass1125!"
        fill_in "新しいパスワード", with: "testcspass1126!"
        fill_in "新しいパスワード（確認用）", with: ""

        click_button "変更する"

        expect(page).to have_content("パスワード（確認用）を入力してください。")

      end

      it "新しいパスワードと新しいパスワード(確認用)が異なっていると変更できない" do
        fill_in "現在のパスワード", with: "testcspass1125!"
        fill_in "新しいパスワード", with: "testcspass1126!"
        fill_in "新しいパスワード（確認用）", with: "testcspass1127!"

        click_button "変更する"

        expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません。")

      end

      it "新しいパスワードが6文字未満だと変更できない" do
        fill_in "現在のパスワード", with: "testcspass1125!"
        fill_in "新しいパスワード", with: "pass!"
        fill_in "新しいパスワード（確認用）", with: "pass!"

        click_button "変更する"

        expect(page).to have_content("パスワードは6文字以上で入力してください。")

      end

    end

    context "ニックネームの変更" do
      before do
        click_link("変更", href: edit_user_nickname_path)
        expect(page).to have_current_path(edit_user_nickname_path)
      end

      it "ニックネームを変更できる" do
        fill_in "新しいニックネーム (10文字以内)", with: "newname"
        click_button "変更する"

        expect(page).to have_current_path(edit_user_registration_path)
        expect(page).to have_content("newname")

      end

      it "空欄のまま変更するとエラーが出る" do
        fill_in "新しいニックネーム (10文字以内)", with: ""
        click_button "変更する"

        expect(page).to have_content("ニックネームを入力してください。")

      end

      it "10文字以上入力するとエラーが出る" do
        fill_in "新しいニックネーム (10文字以内)", with: "10文字以上のニックネーム"
        click_button "変更する"

        expect(page).to have_content("ニックネームは10文字以内で入力してください。")
      end
    end

    context "プロフィール画像の変更" do
      before do
        find('.profile-image-wrapper').click
        expect(page).to have_current_path(edit_user_avatar_path)
      end

      it "プロフィール画像を変更できる" do
        attach_file("新しいプロフィール画像", Rails.root.join("spec/fixtures/files/avatar.png"))
        click_button "変更する"

        expect(page).to have_current_path(edit_user_registration_path)
      end
    end
  end
end
