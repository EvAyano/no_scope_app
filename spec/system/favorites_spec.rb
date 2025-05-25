require 'rails_helper'

RSpec.describe "Favorites", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:user) { User.create!(email: 'test@noscope.com', password: 'testcspass1125!', password_confirmation: 'testcspass1125!', nickname: 'testuser') }

  let!(:word1) do
    Word.create!(
      term: "Nade",
      definition: "グレネードのこと",
      explanation: "「Grenade（グレネード）」の略。",
      example_en: "Throw a nade.",
      example_jp: "グレネード投げて。",
      pronunciation_jp: "ネイド",
      pronunciation_en: "ネイﾄﾞ",
      related_videos: ""
    )
  end

  let!(:word2) do
    Word.create!(
      term: "TK",
      definition: "味方のプレイヤーを誤ってキルしてしまうこと",
      explanation: "Team Kill（チームキル）の略。",
      example_en: "He TK’ed me by mistake.",
      example_jp: "ミスられて彼にキルされた。",
      pronunciation_jp: "チームキル",
      pronunciation_en: "ティーﾑキﾙ",
      related_videos: "BT-R4xm2CG0"
    )
  end

  describe "ログインしている場合" do
    context "単語一覧" do

      it "単語詳細からお気に入り登録ができる" do
        user_login
        visit words_path
        click_link "N"

        within("turbo-frame#word_list") do
          click_link "Nade"
        end

        within("turbo-frame#word_detail") do
          click_button "お気に入りへ追加"
          expect(page).to have_button("お気に入りから削除")
        end

        expect(user.favorites.find_by(word: word1)).to be_present
      end

      it "単語詳細からお気に入り削除ができる" do
        user_login
        user.favorites.create!(word: word1)

        visit words_path
        click_link "N"

        within("turbo-frame#word_list") do
          click_link "Nade"
        end

        within("turbo-frame#word_detail") do
          click_button "お気に入りから削除"
          expect(page).to have_button("お気に入りへ追加")
        end

        expect(user.favorites.find_by(word: word1)).to be_nil
      end

      it "お気に入り登録ボタンが切り替わること" do
        user_login
        visit words_path
        click_link "N"
        
        within("turbo-frame#word_list") do
          click_link "Nade"
        end
      
        within("turbo-frame#word_detail") do
          click_button "お気に入りへ追加"

          expect(page).to have_button("お気に入りから削除")
          expect(page).not_to have_button("お気に入りへ追加")

          click_button "お気に入りから削除"

          expect(page).not_to have_button("お気に入りから削除")

          expect(page).to have_button("お気に入りへ追加")

        end
      end
      

      
    end

    context "お気に入りの単語一覧" do
      it "お気に入りの単語が表示される" do
        user_login
        user.favorites.create!(word: word1)
        user.favorites.create!(word: word2)
        visit favorites_path
        expect(page).to have_content("お気に入りの単語")
        expect(page).to have_content("Nade")
        expect(page).to have_content("TK")
      end

      it "単語の詳細が表示される" do
        user_login
        user.favorites.create!(word: word1)
        visit favorites_path
        click_link "Nade"
        expect(page).to have_selector("turbo-frame#word_detail", text: "Nade", wait: 5)

        within("turbo-frame#word_detail") do
          expect(page).to have_content("Nade")  
          expect(page).to have_content("グレネードのこと")
          expect(page).to have_content("「Grenade（グレネード）」の略。")
          expect(page).to have_content("Throw a nade.")
          expect(page).to have_content("グレネード投げて。")
          expect(page).to have_content("ネイﾄﾞ")
          expect(page).to have_content("関連する動画はありません。")
        end
      end

      it "お気に入りの単語で動画が表示される" do
        fake_video = OpenStruct.new(id: OpenStruct.new(video_id: "FAKEnade22"))
        allow_any_instance_of(YoutubeService).to receive(:search_video).and_return(fake_video)
        user.favorites.create!(word: word1)

        user_login
        visit favorites_path
      
        click_link "Nade"
        expect(page).to have_selector("turbo-frame#word_detail", text: "Nade", wait: 5)

        within("turbo-frame#word_detail") do
          expect(page).to have_css("iframe[src*='youtube.com/embed/FAKEnade22']")
        end
      end

      it "削除すると一覧から消える" do
        user.favorites.create!(word: word1)
        user_login
        visit favorites_path
      
        click_link "Nade"

        expect(page).to have_selector("turbo-frame#word_detail", wait: 5)

        within("turbo-frame#word_detail") do
          click_button "お気に入りから削除"
        end
      
        within("turbo-frame#favorite_word_list") do
          expect(page).not_to have_content("Nade")
        end
      end
      
      it "お気に入りの単語がない場合は表示されない" do
        user_login
        visit favorites_path
        expect(page).to have_content("お気に入りはまだありません。")
      end
    end
  end


  describe "未ログインユーザーの場合" do
    context "単語一覧" do
      it "お気に入り追加ボタンを押すとログインするように表示される" do
        visit words_path
        click_link "N"
      
        within("turbo-frame#word_list") do
          click_link "Nade"
        end
      
        within("turbo-frame#word_detail") do
          click_button "お気に入りへ追加"
        end

        #htmlが表示されるまで待機
        expect(page).to have_selector("turbo-frame#fav_not_login", wait: 5)

        expect(page).to have_text("お気に入りへ追加するにはログインが必要です。")
        expect(page).to have_link("ログインする", href: new_user_session_path)

      end

      
    end
  end
end
