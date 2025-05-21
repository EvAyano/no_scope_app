require 'rails_helper'

RSpec.describe "Words", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

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
      example_jp: "ミスられて彼にキルされた。た",
      pronunciation_jp: "チームキル",
      pronunciation_en: "ティーﾑキﾙ",
      related_videos: "BT-R4xm2CG0"
    )
  end

  describe "単語一覧" do
    it "アルファベットボタンが表示されること" do
      visit words_path
      ("A".."Z").each do |letter|
        expect(page).to have_link(letter)
      end
    end

    it "該当する単語が存在するアルファベットを選ぶと単語が表示される" do
      visit words_path
      expect(page).to have_selector("turbo-frame#word_list")
      click_link "N"

      within("turbo-frame#word_list") do
        expect(page).to have_content("Nade")
        expect(page).to have_content("グレネードのこと")
      end
    end

    it "該当する単語がない場合はメッセージが表示される" do
      visit words_path
      click_link "Q"

      within("turbo-frame#word_list") do
        expect(page).to have_content("Qから始まる単語は見つかりませんでした")
      end
    end
  end

  describe "単語の詳細" do
    it "単語リンクをクリックすると詳細が表示される" do
      visit words_path
      click_link "N"

      within("turbo-frame#word_list") do
        click_link "Nade"
      end

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

    it "単語リンクをクリックすると詳細と動画が表示される" do
      visit words_path
      click_link "T"

      within("turbo-frame#word_list") do
        click_link "TK"
      end

      within("turbo-frame#word_detail") do
        expect(page).to have_content("TK")
        expect(page).to have_content("味方のプレイヤーを誤ってキルしてしまうこと")
        expect(page).to have_content("Team Kill（チームキル）の略。")
        expect(page).to have_content("He TK’ed me by mistake.")
        expect(page).to have_content("ミスられて彼にキルされた。")
        expect(page).to have_content("ティーﾑキﾙ")
        expect(page).to have_selector("iframe[src='https://www.youtube.com/embed/BT-R4xm2CG0']")
        
      end
    end

    it "APIから取得したYouTube動画が表示される" do
      fake_video = OpenStruct.new(id: OpenStruct.new(video_id: "FAKEnade22"))
    
      allow_any_instance_of(YoutubeService).to receive(:search_video).and_return(fake_video)
    
      visit words_path
      click_link "N"
    
      within("turbo-frame#word_list") do
        click_link "Nade"
      end
    
      within("turbo-frame#word_detail") do
        expect(page).to have_css("iframe[src*='youtube.com/embed/FAKEnade22']",wait: 5)
      end
    end
    
  end

  describe "検索機能" do

    it "空で検索すると結果が表示されない" do
      visit search_words_path(q: "")
      within("turbo-frame#word_list") do
        expect(page).to have_content("検索結果はありません。")
      end
    end

    it "日本語で検索すると該当の単語が表示される" do
      visit search_words_path(q: "投げ")

      within("turbo-frame#word_list") do
        expect(page).to have_content("Nade")
      end
    end

    it "英単語で検索すると該当の単語が表示される" do
      visit search_words_path(q: "Nade")

      within("turbo-frame#word_list") do
        expect(page).to have_content("Nade")
      end
    end

    it "英語と日本語両方で検索すると何もヒットしない" do
      visit search_words_path(q: "TKグレ")
      within("turbo-frame#word_list") do
        expect(page).to have_content("検索結果はありません。")
      end
    end

    it "アルファベット1文字で検索するとその文字から始まる単語が表示される" do
      visit search_words_path(q: "T")

      within("turbo-frame#word_list") do
        expect(page).to have_content("TK")
      end
    end

    it "存在しない単語を検索した場合はメッセージが表示される" do
      visit search_words_path(q: "heroic")

      within("turbo-frame#word_list") do
        expect(page).to have_content("検索結果はありません。")
      end
    end

    it "検索結果で単語詳細を表示できる" do
      visit search_words_path(q: "TK")
    
      within("turbo-frame#word_list") do
        click_link "TK"
      end
    
      within("turbo-frame#word_detail") do
        expect(page).to have_content("Team Kill")
      end
    end
    
  end
end
