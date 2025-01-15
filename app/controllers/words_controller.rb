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
      video = youtube_service.search_video(query)
      @youtube_video_id = video&.id&.video_id
    end

    respond_to do |format|
      format.html do
        render partial: 'words/word_detail', locals: { word: @word, youtube_video_id: @youtube_video_id }
      end
      format.turbo_stream do
        render partial: 'words/word_detail', locals: { word: @word, youtube_video_id: @youtube_video_id }
      end
    end
  end
end
