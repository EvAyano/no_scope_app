require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'アカウントの作成時' do
      let!(:user) { User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser') }

      it 'ニックネームがnilではアカウントを作れない' do
        user.nickname = nil
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to match_array(["を入力してください。"])
      end

      it 'ニックネームが空の場合はアカウントを作れない' do
        user.nickname = ''
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to match_array(["を入力してください。"])
      end

      it 'ニックネームが10文字を超えるとアカウントを作れない' do
        user.nickname = 'more than 10moji no nickname'
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to match_array(["は10文字以内で入力してください。"])
      end

      it 'メールアドレスがnilだとアカウントを作れない' do
        user.email = nil
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:email]).to match_array(["を入力してください。"])
      end

      it 'メールアドレスが空だとアカウントを作れない' do
        user.email = ''
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:email]).to match_array(["を入力してください。"])
      end

      it '無効なメールアドレスではエラーが出る' do
        invalid_emails = ['invalid_email', 'invalid@', '@invalid.com', 'invalid email@noscope.com']
        invalid_emails.each do |email|
          user.email = email
          user.valid?
          expect(user).not_to be_valid
          expect(user.errors[:email]).to match_array(["は不正な値です。"])
        end
      end

      it '同じメールアドレスのユーザーを作成できない' do
        duplicate_user = User.new(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser2')
        duplicate_user.valid?
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to match_array(["はすでに存在します。"])
      end      

      it 'パスワードがnilではアカウントを作れない' do
        user.password = nil
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:password]).to match_array(["を入力してください。"])
      end

      it 'パスワードが空だとアカウントを作れない' do
        user.password = ''
        user.password_confirmation = ''
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:password]).to match_array(["を入力してください。"])
      end

      it '確認用パスワードがnilではアカウントを作れない' do
        user.password_confirmation = nil
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to match_array(["を入力してください。"])
      end

      it '確認用パスワードが空だとアカウントを作れない' do
        user.password_confirmation = ''
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to match_array(["とパスワードの入力が一致しません。", "を入力してください。"])
      end

      it 'パスワードと確認用パスワードが一致しないとアカウントを作れない' do
        user.password_confirmation = 'not same password'
        user.valid?
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to match_array(["とパスワードの入力が一致しません。"])
      end

      it 'すべての必須情報が欠けている場合、アカウントを作成できない' do
        user = User.new(email: nil, password: nil, password_confirmation: nil, nickname: nil)
        user.valid?

        expect(user).not_to be_valid
        expect(user.errors[:email]).to match_array(["を入力してください。"])
        expect(user.errors[:password]).to match_array(["を入力してください。"])
        expect(user.errors[:password_confirmation]).to match_array(["を入力してください。"])
        expect(user.errors[:nickname]).to match_array(["を入力してください。"])
      end

      it 'すべての必須情報が空文字の場合、アカウントを作成できない' do
        user = User.new(email: '', password: '', password_confirmation: '', nickname: '')
        user.valid?
      
        expect(user).not_to be_valid
        expect(user.errors[:email]).to match_array(["を入力してください。"])
        expect(user.errors[:password]).to match_array(["を入力してください。"])
        expect(user.errors[:password_confirmation]).to match_array(["を入力してください。"])
        expect(user.errors[:nickname]).to match_array(["を入力してください。"])
      end

      it '必要な情報がすべてあればアカウントを作成できる' do
        user.valid?
        expect(user).to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    let!(:user) { User.create!(email: 'test@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser') }
    
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

    before { user.quizzes << Quiz.create!(start_time: Time.current, completed: true) }

    context 'quizzesの関連付け' do
      let!(:quiz) { user.quizzes.first }

      it 'quizzesを持つことができる' do
        expect(user.quizzes).to include(quiz)
      end

      it 'ユーザーを削除すると quizzesも削除される' do
        expect { user.destroy }.to change { Quiz.count }.by(-1)
      end
    end

    context 'favoritesの関連付け' do
      it '多数のお気に入り登録を持つことができる' do
        favorite = Favorite.create!(user: user, word: test_word)
        user.favorites << favorite
        expect(user.favorites).to include(favorite)
      end

      it 'ユーザーを削除するとお気に入り登録も削除される' do
        user.favorites << Favorite.create!(user: user, word: test_word)
        expect { user.destroy }.to change { Favorite.count }.by(-1)
      end
    end

    context 'favorite_wordsの関連付け' do
      it '多数のお気に入りの単語を持つことができる' do
        user.favorites << Favorite.create!(user: user, word: test_word)
        expect(user.favorite_words).to include(test_word)
      end
    end
  end
end
