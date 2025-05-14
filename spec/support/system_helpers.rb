module SystemHelpers
  def user_login
    visit new_user_session_path
    fill_in "メールアドレス", with: "test@noscope.com"
    fill_in "パスワード", with: "password"
    click_button "ログイン"
  end
end
  