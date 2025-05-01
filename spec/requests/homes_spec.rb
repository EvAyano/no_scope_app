require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    context "クイズ結果があるとき" do
        before do
          user = User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
          quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)
          quiz.quiz_questions.create!(word:Word.create!(
            term: 'CSword', 
            definition: 'CSword no imi',
            explanation: 'Counter Strike no word',
            example_en: 'Kauntaa Sutoraiku sentence',
            example_jp: 'Counter Strike sentence',
            pronunciation_jp: 'Shiesu',
            pronunciation_en: 'CS'
          ), user_answer: "CSword", correct: true, choices: ["CSword", "Other1", "Other2", "Other3"])
        end

        it "ホーム画面にクイズ結果部分が表示されること" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("最新の10件")
      end
    end

    context "クイズ結果がないとき" do
      before do
        Quiz.delete_all
      end
      
      it "クイズ結果部分が表示されないこと" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("まだクイズを受けた人がいません")
      end
    end
  end

  context "ログインしていないとき" do
    it "home/logged_outのパーシャルが表示されること" do
      get root_path
      expect(response.body).to include("ぜひログインして")
    end
  end

  context "ログインしているとき" do
    let(:user) { User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser') }

    it "home/logged_inパーシャル(空)が表示されること" do
      post user_session_path, params: { user: { email: user.email, password: "password" } }
      get root_path
      expect(response.body).to include("ログアウト")
    end
  end
end
