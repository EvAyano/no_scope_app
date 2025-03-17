require 'rails_helper'

RSpec.describe Word, type: :model do
  describe 'バリデーション' do
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

    it 'termがなければ無効である' do
      word.term = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '定義がなければ無効である' do
      word.definition = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '説明がなければ無効である' do
      word.explanation = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '英語の例文がなければ無効である' do
      word.example_en = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '日本語の例文がなければ無効である' do
      word.example_jp = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '日本語の発音がなければ無効である' do
      word.pronunciation_jp = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '英語の発音がなければ無効である' do
      word.pronunciation_en = nil
      word.valid?
      expect(word).not_to be_valid
    end

    it '関連動画が空でもOK' do
      word.related_videos = nil
      word.valid?
      expect(word).to be_valid
    end

    it '関連動画が正しい形式なら有効' do
      valid_formats = ['video123', 'test_video', 'test-video01', 'TESTVIDEO']
      valid_formats.each do |valid|
        word.related_videos = valid
        word.valid?
        expect(word).to be_valid
      end
    end

    it '関連動画が不正な形式の場合、無効である' do
      invalid_formats = ['test video', 'video@123', 'test.video', 'test#123', '日本語のID']
      invalid_formats.each do |invalid|
        word.related_videos = invalid
        word.valid?
        expect(word).not_to be_valid
      end
    end
  end
end
