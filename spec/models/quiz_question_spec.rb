require 'rails_helper'

RSpec.describe QuizQuestion, type: :model do
  describe 'アソシエーション' do
    it { is_expected.to belong_to(:quiz) }
    it { is_expected.to belong_to(:word) }
  end

  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:quiz_id) }
    it { is_expected.to validate_presence_of(:word_id) }
    it { is_expected.to allow_value(true).for(:correct)}
    it { is_expected.to allow_value(false).for(:correct)}
    it { is_expected.not_to allow_value(nil).for(:correct) }
  end

  describe 'インスタンスメソッド' do
    let(:word) do
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

    let(:quiz) { Quiz.create!(start_time: Time.current, completed: true) }

    it '#is_correct_answer?で正しい答えを判定' do
      quiz_question = QuizQuestion.create(quiz: quiz, word: word)

      expect(quiz_question.is_correct_answer?('CSword')).to be true
      expect(quiz_question.is_correct_answer?('wrong_term')).to be false
    end

    it '#correctness_textで正誤の表示をする' do
      quiz_question = QuizQuestion.create(quiz: quiz, word: word, correct: true)
      expect(quiz_question.correctness_text).to eq('正解')
      
      quiz_question.update(correct: false)
      expect(quiz_question.correctness_text).to eq('不正解')
    end
  end
end
