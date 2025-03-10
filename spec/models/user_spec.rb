require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'アカウントの作成時' do
      it 'ニックネーム設定なしではアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: nil)
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to include("を入力してください")
      end

      it 'ニックネームが10文字を超えるとアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'a' * 11)
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to include("は10文字以内で入力してください")
      end

      it 'メールアドレスなしではアカウントを作れない' do
        user = User.new(email: nil, password: 'password', password_confirmation: 'password', nickname: 'testuser')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it '無効なメールアドレスではアカウントを作れない' do
        invalid_emails = ['invalid_email', 'invalid@', '@invalid.com', 'invalid email@noscope.com']
        
        invalid_emails.each do |email|
          user = User.new(email: email, password: 'password', password_confirmation: 'password', nickname: 'testuser')
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include("は不正な値です")
        end
      end

      it '同じメールアドレスのユーザーを作成できない' do
        User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
        duplicate_user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser2')
        
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include("はすでに存在します")
      end      

      it 'パスワードなしではアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: nil, password_confirmation: nil, nickname: 'testuser')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("を入力してください")
      end

      it '確認用パスワードなしではアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: nil, nickname: 'testuser')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("を入力してください")
      end

      it 'パスワードが6文字未満ではアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: 'short', password_confirmation: 'short', nickname: 'testuser')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("は6文字以上で入力してください")
      end

      it 'パスワードと確認用パスワードが一致しないとアカウントを作れない' do
        user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: 'different', nickname: 'testuser')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
      end

      it '必要な情報がすべてあればアカウントを作成できる' do
        user = User.new(
          email: 'test@noscope.com',
          password: 'password',
          password_confirmation: 'password',
          nickname: 'testuser'
        )
        expect(user).to be_valid
      end

      it 'すべての必須情報が欠けている場合、アカウントを作成できない' do
        user = User.new(email: nil, password: nil, password_confirmation: nil, nickname: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
        expect(user.errors[:password]).to include("を入力してください")
        expect(user.errors[:password_confirmation]).to include("を入力してください")
        expect(user.errors[:nickname]).to include("を入力してください")
      end
    end
  end

  describe '#display_avatar' do
    it 'アバターが設定されていない場合、デフォルト画像で設定' do
      user = User.create(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
      expect(user.display_avatar).to eq("user-default-image.png")
    end

    it 'アバターが設定されている場合、リサイズされる' do
      user = User.create(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser')
      user.avatar.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'avatar.png')), filename: 'avatar.png', content_type: 'image/png')
      expect(user.display_avatar).to be_an_instance_of(ActiveStorage::VariantWithRecord)
    end
  end
end
