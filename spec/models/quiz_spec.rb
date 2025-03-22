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
end
