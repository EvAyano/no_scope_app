class WordsController < ApplicationController
  
  def index
    @letters = ('A'..'Z').to_a
    @words = nil
    @message = "アルファベットを選択してください"
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
    @word = Word.find(params[:id])

    respond_to do |format|
      format.html do
        render partial: 'words/word_detail', locals: { word: @word }
      end
      format.turbo_stream do
        render partial: 'words/word_detail', locals: { word: @word }
      end
    end
  end
  

  

  private

  def set_word
    word_id = params[:word_id] || params[:selected_word_id]

    Rails.logger.debug "set_wordで params[:word_id]: #{params[:word_id]}"
    Rails.logger.debug "取得したword_id: #{word_id}"

    @word = Word.find(word_id)
  end
   
end
