require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'アカウントの作成時' do
      it 'ニックネーム設定なしではアカウントを作れない' do
        user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password', nickname: nil)
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to include("を入力してください")
      end

      it 'ニックネームの設定があればアカウントを作れる' do
        user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
        expect(user).to be_valid
      end
    end
  end
end
