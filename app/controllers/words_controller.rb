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
end
