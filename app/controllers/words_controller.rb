class WordsController < ApplicationController
  
  def index
    @letters = ('A'..'Z').to_a
    @words = nil
    @message = "アルファベットを選択すると、その文字から始まる単語がここに表示されます"
    @words_present = false
  end
  

  def filter
    @letter = params[:letter].upcase
    @words = Word.where('term LIKE ?', "#{@letter}%").order(:term)
  
    if @words.any?
      @message = nil
      @words_present = true
    else
      @message = "#{@letter}から始まる単語は見つかりませんでした。"
      @words_present = false
    end
  
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'words/initial_before_filter', locals: { words: @words, message: @message, words_present: @words_present } }
    end
  end

  def search
    @query = params[:q].to_s.strip

    if @query.empty?
      @words = []
    else
      if is_japanese?(@query)
        @words = japanese_search(@query)
      else
        @words = english_search(@query)
      end
    end

    @message = @words.any? ? nil : "検索結果はありません。"

    render "words/search_result", locals: { words: @words, message: @message }
  end

  def show
    unless request.headers["Turbo-Frame"]
      raise ActiveRecord::RecordNotFound
    end

    @word = Word.find(params[:id])

    if @word.related_videos.present?
      @youtube_video_id = @word.related_videos
    else
      youtube_service = YoutubeService.new
      query = "counter strike #{@word.term}"

      begin
        video = youtube_service.search_video(query)
        @youtube_video_id = video&.id&.video_id
      rescue StandardError => e
        Rails.logger.error "YouTubeAPIのエラー: #{e.message}"
        @youtube_video_id = nil
      end
    end

    render partial: 'words/word_detail', locals: { word: @word, youtube_video_id: @youtube_video_id }
  end

  private

  def is_japanese?(str)
    !!(str =~ /[\p{Hiragana}\p{Katakana}\p{Han}]/)
  end

  def english_search(query)
    # 1文字だけの場合 → その文字でterm の先頭一致
    if query.size == 1
      Word.where("term LIKE ?", "#{query}%").order(:term)
    else
      # 2文字以上 → term, definition, explanation, example_en, example_jp の部分一致
      Word.where(
        "term LIKE :q OR definition LIKE :q OR explanation LIKE :q OR example_en LIKE :q OR example_jp LIKE :q",
        q: "%#{query}%"
      ).order(:term)
    end
  end

  def japanese_search(query)
    # definition, explanation, example_jp, pronunciation_jp の部分一致
    Word.where(
      "definition LIKE :q OR explanation LIKE :q OR example_jp LIKE :q OR pronunciation_jp LIKE :q",
      q: "%#{query}%"
    ).order(:term)
  end
end
