class WordsController < ApplicationController
  before_action :set_word, only: [:create_list_and_save_word, :new_list_form]
  
  def new_list_form
    @list = current_user.lists.build
  end
  
  def create_list_and_save_word
    @list = current_user.lists.build(list_params)
    @word = Word.find(params[:word_id])
  
    if @list.save
      @list.words << @word
      flash.now[:notice] = 'リストが作成され、単語が保存されました。'
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to words_path }
      end
    else
      flash.now[:alert] = 'リストは5つまでしか作成できません。'
      respond_to do |format|
        format.turbo_stream { render :create_list_and_save_word, status: :unprocessable_entity }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end
  

  def index
    @letters = ('A'..'Z').to_a
  end

  def show
    @word = Word.find(params[:id])
    @list = current_user.lists.build
  
    respond_to do |format|
      format.html do
        render partial: 'words/word_detail', locals: { word: @word, list: @list }
      end
      format.turbo_stream do
        render partial: 'words/word_detail', locals: { word: @word, list: @list }
      end
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
      format.turbo_stream
      format.html { render partial: 'words/initial_before_filter', locals: { words: @words, letter: @letter } }
    end
  end
  

  private

  def list_params
    params.require(:list).permit(:name)
  end

  def set_word
    word_id = params[:word_id] || params[:selected_word_id]

    Rails.logger.debug "set_wordで params[:word_id]: #{params[:word_id]}"
    Rails.logger.debug "取得したword_id: #{word_id}"

    @word = Word.find(word_id)
  end
   
end
