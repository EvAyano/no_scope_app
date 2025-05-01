require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  let!(:user) { User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser') }
  let!(:word) do
    Word.create!(
      term: 'CSword', 
      definition: 'CSword no imi',
      explanation: 'Counter Strike no word',
      example_en: 'Kauntaa Sutoraiku sentence',
      example_jp: 'Counter Strike sentence',
      pronunciation_jp: 'Shiesu',
      pronunciation_en: 'CS'
    )
  end

  describe "GET/favorites" do
    context "ログインしているとき" do
      it "お気に入りの単語一覧が表示されること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }

        favorite = user.favorites.create!(word: word)

        get favorites_path
  
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("お気に入りの単語")
        expect(response.body).to include(word.term)
      end
    end
  
    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        get favorites_path
  
        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "POST/favorites" do
    context "ログインしているとき" do
      it "お気に入り登録できること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }
  
        expect {post favorites_path, params: { word_id: word.id }}.to change { user.favorites.count }.by(1)
        expect(response).to have_http_status(:ok).or have_http_status(:found)
      end
    end
  
    context "ログインしていないとき" do
      it "ログインするように表示されること" do
        post favorites_path, params: { word_id: word.id }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
  
        expect(response.content_type).to include("turbo-stream")
        expect(response.body).to include("お気に入りへ追加するにはログインが必要です。")
      end
    end
  end

  describe "DELETE/favorites/id" do
    context "ログインしているとき" do
      it "お気に入り単語リスト上ででお気に入りを削除できること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }
        favorite = user.favorites.create!(word: word)

        expect {delete favorite_path(favorite)}.to change { user.favorites.count }.by(-1)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(favorites_path)
      end

      it "単語リスト上ではTurbo Streamでお気に入りを削除できること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }
        favorite = user.favorites.create!(word: word)

        expect {delete favorite_path(favorite), headers: { "Accept" => "text/vnd.turbo-stream.html" }}.to change { user.favorites.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("turbo-stream")
      end
    end

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        favorite = user.favorites.create!(word: word)

        delete favorite_path(favorite)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
