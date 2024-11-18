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
        format.turbo_stream do
          render turbo_stream: [
            # 成功時：フラッシュメッセージ更新
            turbo_stream.replace("new_list_flash", partial: "shared/flash_message", locals: { message: flash[:notice], alert: false, frame_id: "new_list_flash" }),
            # 成功時：既存リストのリストを更新
            turbo_stream.replace("existing_list", partial: "words/lists", locals: { lists: current_user.lists, word: @word }),
            # 成功時：フォーム更新
            turbo_stream.replace("new_list", partial: "words/form", locals: { list: List.new, word: @word })
          ]
        end
        format.html { redirect_to words_path }
      end
    else
      flash.now[:alert] = 'リストは5つまでしか作成できません。'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            # 失敗時：フラッシュメッセージ更新
            turbo_stream.replace("new_list_flash", partial: "shared/flash_message", locals: { message: flash[:alert], alert: true, frame_id: "new_list_flash" }),
            # 失敗時：リスト作成フォーム更新
            turbo_stream.replace("new_list", partial: "words/form", locals: { list: @list, word: @word })
          ], status: :unprocessable_entity
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def add_word_to_existing_list
    @list = current_user.lists.find(params[:existing_list_id])
    @word = Word.find(params[:word_id])
  
    if @list.words.include?(@word)
      # 単語が既にリストに存在する場合
      @message = 'すでに追加されています。'
      @alert = true
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "existing_list_flash",
            partial: "shared/flash_message",
            locals: { message: @message, alert: @alert, frame_id: "existing_list_flash" }
          )
        end
        format.html { redirect_to words_path, alert: @message }
      end
    else
      # 単語がリストに存在しない場合、新規追加
      if @list.words << @word
        @message = '単語が既存リストに保存されました。'
        @alert = false
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "existing_list_flash",
              partial: "shared/flash_message",
              locals: { message: @message, alert: @alert, frame_id: "existing_list_flash" }
            )
          end
          format.html { redirect_to words_path, notice: @message }
        end
      else
        @message = '単語の保存に失敗しました。'
        @alert = true
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "existing_list_flash",
              partial: "shared/flash_message",
              locals: { message: @message, alert: @alert, frame_id: "existing_list_flash" }
            ),
            status: :unprocessable_entity
          end
          format.html { render :index, alert: @message, status: :unprocessable_entity }
        end
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
