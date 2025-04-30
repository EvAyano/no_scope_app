require 'rails_helper'

RSpec.describe "Words", type: :request do
  let!(:word) do
    Word.create!(
      term: 'CSword', 
      definition: 'CSword no imi',
      explanation: 'Counter Strike no word',
      example_en: 'Kauntaa Sutoraiku sentence',
      example_jp: 'Counter Strike sentence',
      pronunciation_jp: 'Shiesu',
      pronunciation_en: 'CS',
      related_videos: 'test_youtube_id'
    )
  end
  
  let!(:word2) do
    Word.create!(
      term: 'Moku',
      definition: '視界を遮るための煙',
      explanation: 'もくもくの説明文。',
      example_en: '"He’s hiding in the kemuri!"',
      example_jp: '敵がモクの中で隠れてる！',
      related_videos: nil,
      pronunciation_jp: 'スモーク',
      pronunciation_en: 'スモーｸ'
    )
  end

  describe "GET /words" do
    it "アルファベット一覧が表示されること" do
      get words_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("アルファベットを選択すると")
    end

    context "アルファベットでフィルターした時" do
      it "該当の単語がある場合、一覧として表示されること" do
        get filter_words_path, params: { letter: 'C' }
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("CSword")
      end

      it "該当の単語がない場合、表示されないこと" do
        get filter_words_path, params: { letter: 'D' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("から始まる単語は見つかりませんでした")
      end
    end

    it "単語の詳細が表示されること" do
      get word_path(word), headers: {"Turbo-Frame" => "word_detail"}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("CSword")

      expect(response.body).to include("CSword no imi")
      expect(response.body).to include("Counter Strike no word")
      expect(response.body).to include("Kauntaa Sutoraiku sentence")
      expect(response.body).to include("test_youtube_id")
    end

    describe "GET/words/search" do
      context "日本語で検索したとき" do
        it "definitionでヒットすること" do
          get search_words_path, params: { q: '煙' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Moku')
        end
      
        it "explanationでヒットすること" do
          get search_words_path, params: { q:'もくもく' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Moku')
        end
      
        it "example_jpでヒットすること" do
          get search_words_path, params: { q: 'モク' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Moku')
        end

        it "pronunciation_jpでヒットすること" do
          get search_words_path, params: { q: 'スモーク' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Moku')
        end
      end

      context "英語で検索したとき" do
        it "termと一致してヒットの結果が返ること" do
          get search_words_path, params: { q:"Moku"}
    
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Moku")
        end

        it "1文字で検索された場合にその文字から始まる単語がヒットすること" do
          get search_words_path, params: { q:"C"}
    
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("CSword")
        end
      end
    
      context "ヒットするような単語がないワードで検索したとき" do
        it "検索結果がないメッセージが表示されること" do
          get search_words_path, params: { q: "x" }
    
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("検索結果はありません。")
        end

        it "検索結果がないメッセージが表示されること" do
          get search_words_path, params: { q: "魚" }
    
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("検索結果はありません。")
        end
      end
    
      context "空白で検索したとき" do
        it "検索結果がないメッセージが表示されること" do
          get search_words_path, params: { q: "" }
    
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("検索結果はありません。")
        end
      end
    end
  end
end
