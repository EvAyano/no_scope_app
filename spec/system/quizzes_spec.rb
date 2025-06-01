require 'rails_helper'


RSpec.describe "Quizzes", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:user) { User.create!(email: 'test@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser') }
  let!(:empty_user) {User.create!(email: 'test2@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser2')}
  let!(:other_user) {User.create!(email: 'test3@noscope.com', password: 'password', password_confirmation: 'password', nickname: 'testuser3')}

  let!(:words) do
    10.times.map do |i|
      Word.create!(
        term: "word#{i}",
        definition: "def#{i}",
        explanation: "exp#{i}",
        example_en: "ex_en#{i}",
        example_jp: "ex_jp#{i}",
        pronunciation_jp: "pronun_jp#{i}",
        pronunciation_en: "pronun_en#{i}",
        related_videos: ""
      )
    end
  end

  it "ログインしていないときはゲストとして受けるボタンとログインボタンが表示される" do
    visit play_quizzes_path(state: 'new')
    expect(page).to have_button("ゲストユーザーとしてクイズ開始")
    expect(page).to have_link("ログイン", href: new_user_session_path)
  end

  it "ログインしているときはクイズ開始ボタンが表示される" do
    user_login
    visit play_quizzes_path(state: 'new')
    expect(page).to have_button("クイズ開始")
  end

  it "ユーザーがクイズを開始して、10問回答して結果を確認できる" do
    user_login

    visit play_quizzes_path(state: 'new')
    click_button "クイズ開始"

    10.times do |i|
      find("label[for^='quiz_choice_']", match: :first, wait: 5).click

      # first("label[for^='quiz_choice_']").click
      click_button "回答"

      expect(page).to have_content("正解").or have_content("不正解")
      expect(page).to have_selector("a.submit-button", text: /(次へ進む|結果を見る)/)
      find("a.submit-button").click
    end

    expect(page).to have_content("クイズ結果")
    expect(page).to have_content("スコア")
    expect(page).to have_selector("table.quiz-results-table")

    expect(page.text).to match(/スコア:\s+\d+\/10/)
  end

  it "9問目までは「次へ進む」、10問目で『結果を見る』が表示される" do
    user_login

    visit play_quizzes_path(state: 'new')
    click_button "クイズ開始"
  
    9.times do
      first("label[for^='quiz_choice_']").click
      click_button "回答", disabled: false, wait: 5

      find("a.submit-button", text: "次へ進む").click
    end
  
    first("label[for^='quiz_choice_']").click
    click_button "回答"
  
    expect(page).to have_link("結果を見る")
  end

  it "ゲストユーザーでもクイズを開始できる" do
    visit play_quizzes_path(state: 'new')
    click_button "ゲストユーザーとしてクイズ開始"
  
    # expect(page).to have_selector("p.quiz-definition")
    expect(page).to have_selector("p.quiz-definition", wait: 5)

  end

  it "選択せずに回答するとエラーが表示される" do
    visit play_quizzes_path(state: 'new')
    click_button "クイズ開始"
    click_button "回答"
  
    expect(page).to have_content("選択肢を1つ選んでください。")
  end

  it "ゲストユーザーが自分のクイズ結果を見られる" do
    visit play_quizzes_path(state: 'new')
    click_button "ゲストユーザーとしてクイズ開始"
  
    10.times do
      find("label[for^='quiz_choice_']", match: :first).click
      click_button "回答"
      find("a.submit-button").click
    end
  
    expect(page).to have_content("クイズ結果")
  end

  it "ゲストが他人のクイズ結果にアクセスするとエラーになる" do
    quiz = Quiz.create!(completed: true, start_time: Time.current)
    quiz.quiz_questions.create!(word: words.first, correct: true)
  
    visit play_quizzes_path(state: 'results', id: quiz.id)
    expect(page).to have_content("ActiveRecord::RecordNotFound") 

  end

  it "ログインユーザーが他人のクイズにアクセスするとエラーになる" do
    quiz = Quiz.create!(user: other_user, completed: true, start_time: Time.current)
    quiz.quiz_questions.create!(word: words.first, correct: true)
  
    user_login
    visit play_quizzes_path(state: 'results', id: quiz.id)
    expect(page).to have_content("ActiveRecord::RecordNotFound") 
  end

  describe "クイズ履歴ページ" do
    context "クイズ履歴のあるユーザー場合" do
      before do
        user_login
        
        #ログイン完了を待つ
        find('.dropdown-toggle').click
        # expect(page).to have_link('お気に入り単語一覧', href: favorites_path)
        expect(page).to have_link('お気に入り単語一覧', href: favorites_path, wait: 5)

        quiz1 = Quiz.create!(user: user, completed: true, start_time: Time.zone.local(2025, 4, 10, 12), score: 8)
        quiz2 = Quiz.create!(user: user, completed: true, start_time: Time.zone.local(2025, 5, 25, 12), score: 10)

        10.times do |i|
          quiz1.quiz_questions.create!(word: words[i], correct: i < 8)
          quiz2.quiz_questions.create!(word: words[i], correct: i < 10)
        end
      end
    
      it "過去のクイズ履歴が表示される" do 
        visit history_quizzes_path
    
        expect(page).to have_content("過去のクイズ履歴")
        expect(page).to have_selector("turbo-frame#quiz_history_frame")

        within("turbo-frame#quiz_history_frame") do
          expect(page).to have_text("8/10")
          expect(page).to have_text("10/10")
        end
      end
    
      it "月をフィルターすると対象の履歴のみが表示される" do
        visit history_quizzes_path
    
        select "2025", from: "year"
        select "4", from: "month"
        click_button "フィルター"
    
        expect(page).to have_content("2025-04-10")
        expect(page).not_to have_content("2025-05-25")
      end

      it "履歴が20件以上の場合にページネーションが表示される" do

        25.times do |i|
          quiz = Quiz.create!(user: user, completed: true, start_time: Time.zone.now - i.days, score: 5)
          10.times { |j| quiz.quiz_questions.create!(word: words[j], correct: j < 3) }
        end
      
        visit history_quizzes_path
        expect(page).to have_selector(".pagination-controls")
        expect(page).to have_link("次へ")
      end      

      it "フィルターした月に履歴がなければメッセージが表示される" do
        visit history_quizzes_path
    
        select "2024", from: "year"
        select "3", from: "month"
        click_button "フィルター"

        expect(page).to have_content("該当するクイズ履歴がありません。")
      end
    end

    context "クイズ履歴のないユーザーの場合" do
      it "履歴がないメッセージが表示される" do
        visit new_user_session_path
    
        fill_in "user_email", with: "test2@noscope.com"
        fill_in "user_password", with: "testcspass1125!"
        click_button "ログイン"
  
        #ログイン完了を待つ
        find('.dropdown-toggle').click
        # expect(page).to have_link('お気に入り単語一覧', href: favorites_path)
        expect(page).to have_link('お気に入り単語一覧', href: favorites_path, wait: 5)

        visit history_quizzes_path
    
        expect(page).to have_content("該当するクイズ履歴がありません。")
      end
    end
  end

  it "未ログイン時に履歴ページにアクセスするとログイン画面に遷移する" do
    visit history_quizzes_path
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content("ログイン")
    expect(page).to have_field("メールアドレス")
    expect(page).to have_field("パスワード")
  end
end
