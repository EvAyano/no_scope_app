require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'バリデーション' do
    let(:valid_test_inquiry) { Contact.new(name: 'スコープさん', email: 'test@noscope.com', message: 'お問い合わせ内容') }

    it '名前の入力がないとエラーになる' do
      valid_test_inquiry.name = nil
      valid_test_inquiry.valid?
      expect(valid_test_inquiry).not_to be_valid

      expect(valid_test_inquiry.errors[:name]).to match_array(["を入力してください。"])
    end

    it '名前が10文字を超えるとエラーになる' do
      valid_test_inquiry.name = 'あ' * 11
      valid_test_inquiry.valid?
      expect(valid_test_inquiry).not_to be_valid

      expect(valid_test_inquiry.errors[:name]).to match_array(["は10文字以内で入力してください。"])
    end

    it 'メッセージ(お問い合わせ内容)がないとエラーが出る' do
      valid_test_inquiry.message = nil
      valid_test_inquiry.valid?
      expect(valid_test_inquiry).not_to be_valid

      expect(valid_test_inquiry.errors[:message]).to match_array(["を入力してください。"])
    end

    it 'メッセージ(お問い合わせ内容)が1000文字を超えるとエラーになる' do
      valid_test_inquiry.message = 'あ' * 1001
      valid_test_inquiry.valid?
      expect(valid_test_inquiry).not_to be_valid

      expect(valid_test_inquiry.errors[:message]).to match_array(["は1000文字以内で入力してください。"])
    end

    it '名前とメッセージ(お問い合わせ内容)があれば有効' do
      expect(valid_test_inquiry).to be_valid
    end

    it 'メールアドレスがなくても有効' do
      valid_test_inquiry.email = nil
      expect(valid_test_inquiry).to be_valid
    end

    it 'メールアドレスの入力がある場合に不正な値だとエラーが出る' do
      invalid_emails = ['invalid_email', 'invalid@', '@invalid.com', 'invalid email@noscope.com']
      invalid_emails.each do |email|
        valid_test_inquiry.email = email
        valid_test_inquiry.valid?

        expect(valid_test_inquiry).not_to be_valid
        expect(valid_test_inquiry.errors[:email]).to match_array(["は不正な値です。"])
      end
    end

    it '名前が空の場合は無効' do
      valid_test_inquiry.name = ''
      expect(valid_test_inquiry).not_to be_valid
      valid_test_inquiry.valid?

      expect(valid_test_inquiry.errors[:name]).to match_array(["を入力してください。"])
    end

    it 'メッセージ(お問い合わせ内容)が空の場合は無効' do
      valid_test_inquiry.message = ''
      expect(valid_test_inquiry).not_to be_valid
      valid_test_inquiry.valid?

      expect(valid_test_inquiry.errors[:message]).to match_array(["を入力してください。"])
    end
  end
end
