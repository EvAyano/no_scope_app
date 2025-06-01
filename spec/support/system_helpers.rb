module SystemHelpers
  def user_login
    visit new_user_session_path
    fill_in "メールアドレス", with: "test@noscope.com"
    fill_in "パスワード", with: "testcspass1125!"
    click_button "ログイン"
  end
end
  