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

    describe "ログインしてクイズを受ける" do
      before do
        post user_session_path, params: { user: {email: user.email, password: "password" } }
      end

      context "state=createのとき" do
        it "クイズが作成され、リダイレクトされる" do
          expect {post play_quizzes_path(state: "create")}.to change { Quiz.where(user_id: user.id).count }.by(1)

          quiz = Quiz.last
          expect(quiz.user).to eq(user)
          expect(response).to redirect_to(play_quizzes_path(state: 'question', id: quiz.id))
        end
      end

      context "state=questionのとき" do
        it "未回答がある場合は質問画面が表示される" do
          quiz = Quiz.create!(user: user, start_time: Time.current)
          quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

          get play_quizzes_path(state: 'question', id: quiz.id)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("回答")
        end

        it "全問回答済みならresultsにリダイレクトされる" do
          quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)
          quiz.quiz_questions.create!(word: word, user_answer: "CSword", correct: true, choices: ["CSword", "Other1", "Other2", "Other3"])

          get play_quizzes_path(state: 'question', id: quiz.id)

          expect(response).to redirect_to(play_quizzes_path(state: 'results', id: quiz.id))
        end
      end

      context "state=answerのとき" do
        it "未回答がある場合は次へ進むボタンが表示される" do
          quiz = Quiz.create!(user: user, start_time: Time.current)
          2.times { quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"]) }

          question = quiz.quiz_questions.first
          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }

          expect(response.body).to include("次へ進む")
        end

        it "全問回答済みなら結果を見るボタンが表示される" do
          quiz = Quiz.create!(user: user, start_time: Time.current)
          question = quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }

          expect(response.body).to include("結果を見る")
        end

        it "回答が未選択ならエラーメッセージが表示される" do
          quiz = Quiz.create!(user: user, start_time: Time.current)
          question = quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])

          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "" }

          expect(response.body).to include("選択肢を1つ選んでください。")
        end
      end

      context "state=resultsのとき" do
        it "自分のクイズ結果を確認できる" do
          quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)
          get play_quizzes_path(state: 'results', id: quiz.id)
          expect(response.body).to include("クイズ結果")
          expect(quiz.reload.score).to be_present
        end

        it "他人のクイズ結果にはアクセスできず404になる" do
          user2 = User.create!(email: 'other@example.com', password: 'password',password_confirmation: 'password',  nickname: 'testuser2')
          quiz = Quiz.create!(user: user2, completed: true, start_time: Time.current)

          post user_session_path, params: { user: { email: user2.email, password: "password" } }
          get play_quizzes_path(state: 'results', id: quiz.id)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "ゲストユーザーとしてクイズを受ける" do
      context "state=createのとき" do
        it "ゲストクイズが作成され、リダイレクトされる" do
          expect {post play_quizzes_path(state: "create")}.to change { Quiz.where(user_id: nil).count }.by(1)

          quiz = Quiz.last
          expect(quiz.user).to be_nil
          expect(response).to redirect_to(play_quizzes_path(state: 'question', id: quiz.id))
        end
      end

      context "state=questionのとき" do
        let(:quiz) do
          Quiz.create!(start_time: Time.current).tap do |quiz|
            quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"])
          end
        end

        let(:rspec_session) { { guest_quiz_ids: [quiz.id] } }

        it "質問画面が表示されること" do
          get play_quizzes_path(state: 'question', id: quiz.id)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('form').and include('回答')
        end

        it "全ての問題に回答済みのときresultsにリダイレクトされること" do
          quiz.update!(completed: true)
          quiz.quiz_questions.first.update!(user_answer: "CSword", correct: true)

          get play_quizzes_path(state: 'question', id: quiz.id)
          expect(response).to redirect_to(play_quizzes_path(state: 'results', id: quiz.id))
        end
      end

      context "state=answerのとき" do
        let(:quiz) do
          Quiz.create!(start_time: Time.current).tap do |quiz|
            2.times{ quiz.quiz_questions.create!(word: word, user_answer: nil, choices: ["CSword", "Other1", "Other2", "Other3"]) }
          end
        end

        let(:rspec_session) { { guest_quiz_ids: [quiz.id] } }

        it "未回答が残っているとき次へ進むボタンが表示される" do
          question = quiz.quiz_questions.first
          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }
          expect(response.body).to include("次へ進む")
        end

        it "全て回答済みなら結果を見るボタンが表示される" do
          first_question = quiz.quiz_questions.first
          first_question.update!(user_answer: "CSword")
          #2問目以降はuser_answerがnil
          quiz.quiz_questions[1..].each do |question|
            question.update!(user_answer: nil)
          end

          question = quiz.quiz_questions.last
          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "CSword" }
          expect(response.body).to include("結果を見る")
        end

        it "回答が未選択のときエラーメッセージが表示される" do
          question = quiz.quiz_questions.first
          post play_quizzes_path(state: 'answer', id: quiz.id, question_id: question.id), params: { answer: "" }
          expect(response.body).to include("選択肢を1つ選んでください。")
        end
      end

      context "context=resultsのとき" do
        let(:quiz) do
          Quiz.create!(completed: true, start_time: Time.current).tap do |quiz|
            quiz.quiz_questions.create!(word: word,user_answer: "CSword",correct: true,choices: ["CSword", "Other1", "Other2", "Other3"])
          end
        end
      
        context "セッションにIDがあるとき" do
          let(:rspec_session) { { guest_quiz_ids: [quiz.id] } }
      
          it "結果が見られる" do
            get play_quizzes_path(state: 'results', id: quiz.id)
            expect(response.body).to include("クイズ結果")
            expect(quiz.reload.score).to be_present
          end
        end
      
        context "セッションにIDがないとき" do
          let(:rspec_session) { { guest_quiz_ids: [] } }
      
          it "404になる" do
            get play_quizzes_path(state: 'results', id: quiz.id)
            expect(response).to have_http_status(:not_found)
          end
        end
      end  
    end
  end

  describe "GET /quizzes/history" do
    context "ログインしているとき" do
      it "履歴がある場合表示されること" do
        post user_session_path, params: { user: {email: user.email, password: "password" } }
        quiz = Quiz.create!(user: user, completed: true, start_time: Time.current)

        get history_quizzes_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("過去のクイズ履歴")
        expect(response.body).to include(quiz.start_time.strftime("%Y-%m-%d"))
        expect(response.body).to include(quiz.score.to_s)
      end

      it "年月で絞り込みができる" do
        post user_session_path, params: { user: { email: user.email, password: "password" } }
      
        start_time = Time.zone.local(2024, 3, 15, 12, 0)
        quiz = Quiz.create!(user: user, completed: true, start_time: start_time)
      
        get history_quizzes_path, params: { year: 2024, month: 3 }, headers: {"HTTP_REFERER" => history_quizzes_path}
      
        expect(response.body).to include(quiz.display_start_time)
      end

      it "履歴がない場合はメッセージが表示される" do
        post user_session_path, params: { user: { email: user.email, password: "password" } }
        get history_quizzes_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("該当するクイズ履歴がありません。")
      end
    end

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされる" do
        get history_quizzes_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
