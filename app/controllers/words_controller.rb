class WordsController < ApplicationController
  def index
    @letters = ('A'..'Z').to_a
  end

  def show
    @word = Word.find(params[:id])
    print"単語の詳細"
    respond_to do |format|
      format.html { render partial: 'words/word_detail', locals: { word: @word } }
      format.turbo_stream { render partial: 'words/word_detail', locals: { word: @word } }
    end
  end

  def save
    @word = Word.find(params[:id])
    list = current_user.lists.find(params[:list_id])

    if list.words << @word
      print "保存できました"
      flash[:notice] = "単語がリストに保存されました。"
    else
      flash[:alert] = "単語の保存に失敗しました。"
    end
    redirect_to @word
  end

  def search
    query = params[:query]
    @words = Word.where('term LIKE ?', "%#{query}%")

    if @words.empty?
      flash[:alert] = "「#{query}」に一致する単語は見つかりませんでした。"
      redirect_to root_path
    else
      render :search_results
    end
  end

  def filter
    @letter = params[:letter].upcase
    @words = Word.where('term LIKE ?', "#{@letter}%")

    respond_to do |format|
      format.turbo_stream { render partial: 'words/initial_before_filter', locals: { words: @words, letter: @letter } }
      format.html { render partial: 'words/initial_before_filter', locals: { words: @words, letter: @letter } }
    end
  end
   
end
