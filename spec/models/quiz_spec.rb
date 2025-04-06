require 'rails_helper'

RSpec.describe Quiz, type: :model do
  before do
    @user = User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
  end

  let(:test_word) do
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

  describe 'バリデーション' do
    it {is_expected.to allow_value(true).for(:completed)}
    it {is_expected.to allow_value(false).for(:completed)}
    it {is_expected.not_to allow_value(nil).for(:completed)}
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user).optional  }
    it { is_expected.to have_many(:quiz_questions).dependent(:destroy) }
  end

  describe 'インスタンスメソッド' do
    let(:quiz) { Quiz.create!(user: @user, start_time: Time.current, completed: true) }

    it '#calculate_and_save_score' do
      quiz.quiz_questions.create!(correct: true, word: test_word)
      quiz.quiz_questions.create!(correct: false, word: test_word)

      quiz.calculate_and_save_score
      expect(quiz.score).to eq(1)
    end

    it '#display_scoreで正しく正答数を計算する' do
      quiz.quiz_questions.create!(correct: true, word: test_word)
      quiz.quiz_questions.create!(correct: false, word: test_word)
    
      quiz.calculate_and_save_score
    
      expect(quiz.display_score).to eq("1/2")
    end
  
    it '#display_scoreでscoreがnilの時は0を返す' do
      quiz.quiz_questions.create!(correct: false, word: test_word)
      quiz.quiz_questions.create!(correct: false, word: test_word)
    
      expect(quiz.display_score).to eq("0/2")
    end
  
    it '#display_usernameで、ログインしている時はユーザー名を表示する' do
      expect(quiz.display_username).to eq("testuser")
    end

    it '#display_usernameで、ログインしていないときはゲストユーザーと表示する' do
      guest_quiz = Quiz.create!(user: nil, start_time: Time.current, completed: true)
      expect(guest_quiz.display_username).to eq("ゲストユーザー")
    end

    it '#display_start_timeで、クイズの開始日時は東京の時間でyy/mm/dd 00:00表示する' do
      expect(quiz.display_start_time).to eq(quiz.start_time.in_time_zone('Tokyo').strftime("%Y-%m-%d %H:%M"))
    end

    it '#display_start_timeで、開始時間がnilの場合は不明と表示する' do
      quiz.start_time = nil
      expect(quiz.display_start_time).to eq("不明")
    end
  end

  describe 'クラスメソッド' do
    before do
      25.times do |i|
        Quiz.create!(user: @user, start_time: Time.zone.local(2025, 3, i + 1, 12), completed: true)
      end
      
      3.times do |i|
        Quiz.create!(user: @user, start_time: Time.zone.local(2025, 4, i + 1, 12), completed: true)
      end

      3.times do |i|
        Quiz.create!(user: @user, start_time: Time.zone.local(2025, 4, i + 1, 11), completed: false)
      end
    end

    describe '#self.paginated_quizzes_for' do

      it '全ての履歴がQuizオブジェクトである' do
        result = Quiz.paginated_quizzes_for(@user)
        expect(result).to all(be_a(Quiz))
      end

      it '完了しているテストのみ取得する' do
        result = Quiz.paginated_quizzes_for(@user)

        all_completed = true
        result.each do |quiz|
          unless quiz.completed == true
            all_completed = false
            break
          end
        end
        expect(all_completed).to be true
      end

      context 'フィルターなしの時' do
        it '1ページ目には全履歴から最新ログを20件(4月3件と3月17件)を取得する' do
          result = Quiz.paginated_quizzes_for(@user, page: 1)

          april_count = result.count { |quiz| quiz.start_time.month == 4 && quiz.start_time.year == 2025}
          march_count = result.count { |quiz| quiz.start_time.month == 3 && quiz.start_time.year == 2025}
        
          expect(result.count).to eq(20)
          expect(april_count).to eq(3)
          expect(march_count).to eq(17)
        end

        it '2ページ目には残り8件(全て3月)を取得する' do
          result = Quiz.paginated_quizzes_for(@user, page: 2)
        
          expect(result.count).to eq(8)
        
          all_march = true
          result.each do |quiz|
            unless quiz.start_time.month == 3 && quiz.start_time.year == 2025
              all_march = false
              break
            end
          end
          expect(all_march).to be true
        end
      end

      context 'フィルターありの時' do
        it 'フィルターされた年月の履歴だけ取得する（１ページ目）' do
          result = Quiz.paginated_quizzes_for(@user, year: 2025, month: 3, page: 1)
          expect(result.all? { |quiz| quiz.start_time.month == 3 && quiz.start_time.year == 2025 }).to be true
          expect(result.count).to eq(20)
        end

        it 'フィルターされた年月の履歴だけ取得する（２ページ目）' do
          result = Quiz.paginated_quizzes_for(@user, year: 2025, month: 3, page: 2)
          expect(result.all? { |quiz| quiz.start_time.month == 3 && quiz.start_time.year == 2025 }).to be true
          expect(result.count).to eq(5)
        end
      end
    end

    describe '#self.fetch_logs_from_relation' do
      it '整形されたログを取得する' do
        paginated_quizzes = Quiz.paginated_quizzes_for(@user)
        quizzes_log = Quiz.fetch_logs_from_relation(paginated_quizzes)
        expect(quizzes_log).to all(include(:id, :formatted_start_time, :score, :path))
      end

      it '整形された内容が正確である' do
        paginated_quizzes = Quiz.paginated_quizzes_for(@user)
        log = Quiz.fetch_logs_from_relation(paginated_quizzes).first
        quiz = paginated_quizzes.first
      
        expect(log[:id]).to eq(quiz.id)
        expect(log[:formatted_start_time]).to eq(quiz.display_start_time)
        expect(log[:score]).to eq(quiz.display_score)
        expect(log[:path]).to include("/quizzes/play?id=#{quiz.id}&state=results")
      end

      it '履歴が存在しないときは「該当するクイズ履歴がありません」のメッセージを取得' do
        history_empty_user = User.create!(email: 'no_quizlog_user@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'empty')
        paginated_quizzes = Quiz.paginated_quizzes_for(history_empty_user)
        quizzes_log = Quiz.fetch_logs_from_relation(paginated_quizzes)
        expect(quizzes_log.first[:message]).to eq("該当するクイズ履歴がありません。")        
      end
    end
  end
end
