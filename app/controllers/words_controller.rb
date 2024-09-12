class WordsController < ApplicationController
  def index
    @letters = ('A'..'Z').to_a
  end

  def initial
    @letter = params[:letter].upcase
    @words = Word.where('term LIKE ?', "#{params[:letter]}%")

    if @words.empty?
      flash[:alert] = "#{@letter}から始まる単語は存在しません。"
      redirect_to words_path
    end
  end

  def show
    @word = Word.find(params[:id])
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
end
