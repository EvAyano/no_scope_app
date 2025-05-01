require 'rails_helper'

RSpec.describe "Quizzes", type: :request do
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

  before do
    20.times do |i|
      Word.create!(
        term: "word#{i}",
        definition: "def#{i}",
        explanation: "exp#{i}",
        example_en: "ex_en#{i}",
        example_jp: "ex_jp#{i}",
        pronunciation_jp: "pronun_jp#{i}",
        pronunciation_en: "pronun_en#{i}"
      )
    end
  end

  describe "GET /quizzes/play" do
    it "stateが不正なときintroが表示されること" do
      get play_quizzes_path(state: 'invalid')
      expect(response.body).to include("4択クイズが10問出されます")
    end

    context "state=newのとき" do
      it "クイズのイントロ画面が表示されること" do
        get play_quizzes_path(state: 'new')
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("4択クイズが10問出されます")
      end
    end

    context "state=createのとき" do
      it "すべての問題の選択肢が4つでその中に正解が1つだけ含まれていること" do
        post play_quizzes_path(state: 'create')
        quiz = Quiz.last

        quiz.quiz_questions.each do |question|
          expect(question.choices.count { |choice| choice == question.word.term }).to eq(1)
          expect(question.choices.size).to eq(4)
        end
      end

      it "10問のクイズが作成されること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }

        post play_quizzes_path(state: 'create')
        quiz = Quiz.last

        expect(quiz.quiz_questions.size).to eq(10)
      end
    end

    context "state=createでログインしているとき" do
      it "ユーザーに紐づいた新規クイズが作成され、question画面へリダイレクトされること" do
        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }

        expect {
          post play_quizzes_path(state: "create")
        }.to change { Quiz.where(user_id: user.id).count }.by(1)

        quiz = Quiz.last
        expect(quiz.user).to eq(user)
        expect(quiz.start_time).to be_present
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(play_quizzes_path(state: 'question', id: quiz.id))
      end
    end

    context "state=createでログインしていないとき" do
      it "user_idがnilのクイズが作成される" do
        expect {
          post play_quizzes_path(state: "create")
        }.to change { Quiz.where(user_id: nil).count }.by(1)

        quiz = Quiz.last
        expect(quiz.user).to be_nil
        expect(quiz.start_time).to be_present
        expect(response).to redirect_to(play_quizzes_path(state: 'question', id: quiz.id))
      end
    end

    context "state=questionのとき" do
      it "未回答の問題が存在するとき質問画面が表示されること" do
        quiz = Quiz.create!(start_time: Time.current)
        quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

        get play_quizzes_path(state: 'question', id: quiz.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('form').and include('回答')
      end

      it "全ての問題に回答済みのときresultsにリダイレクトされること" do
        quiz = Quiz.create!(start_time: Time.current, completed: true)
        quiz.quiz_questions.create!(word: word, user_answer: "CSword", correct: true, choices: ["CSword", "Other1", "Other2", "Other3"])

        get play_quizzes_path(state: 'question', id: quiz.id)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(play_quizzes_path(state: 'results', id: quiz.id))
      end
    end

    context "state=answerのとき" do
      it "未回答の問題が残っている場合、question画面に遷移するボタンが表示されること" do
        quiz = Quiz.create!(start_time: Time.current)
        2.times { quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"]) }

        question = quiz.quiz_questions.first

        post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('form').and include('次へ進む')
      end

      it "すべての問題に回答した場合、resultsへいくボタンが表示されること" do
        quiz = Quiz.create!(start_time: Time.current)
        question = quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

        post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("結果を見る")
      end

      it "回答が未選択の場合、エラーメッセージとともにquestion画面が再表示されること" do
        quiz = Quiz.create!(start_time: Time.current)
        question = quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

        post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("選択肢を1つ選んでください。")
      end
    end

    context "state=resultsのとき" do
      it "結果画面が表示されること" do
        quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)

        get play_quizzes_path(state: 'results', id: quiz.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("クイズ結果")
        expect(quiz.reload.score).to be_present
      end
    end
  end

  describe "GET /quizzes/history" do
    context "ログインしているとき" do
      it "クイズ履歴がある場合は表示されること" do

        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }

        quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)

        get history_quizzes_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("過去のクイズ履歴")
        expect(response.body).to include(quiz.start_time.strftime("%Y-%m-%d"))
        expect(response.body).to include(quiz.score.to_s)
      end

      it "クイズ履歴がない場合は表示されないこと" do

        post user_session_path, params: {
          user: { email: user.email, password: "password" }
        }

        get history_quizzes_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("過去のクイズ履歴")
        expect(response.body).to include("該当するクイズ履歴がありません。")

      end
    end

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされること" do
        get history_quizzes_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
