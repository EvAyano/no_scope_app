require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let!(:user) { User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser') }

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

  describe 'バリデーション' do
    before do
      Favorite.create!(user: user, word: word)
    end

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:word_id) }
    it { is_expected.to validate_presence_of(:word_id) }
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:word) }
  end
end
