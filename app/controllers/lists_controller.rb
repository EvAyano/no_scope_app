class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :change_name, :destroy, :remove_word]

  def index
    @lists = current_user.lists.where.not(id: nil)
    @list = current_user.lists.build
    if @lists.any?
      @lists_index_partial = { partial: 'shared/lists_index_partial', locals: { lists: @lists } }
    else
      @lists_index_partial = { partial: 'shared/no_lists' } 
    end
  end

  def create
    @list = current_user.lists.build(list_params)
    
    if @list.save
      redirect_to lists_path, notice: 'リストが作成されました。'
    else
      @lists = current_user.lists.reload
      @lists_index_partial = if @lists.any?
                               { partial: 'shared/lists_index_partial', locals: { lists: @lists } }
                             else
                               { partial: 'shared/no_lists' }
                             end
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @words = @list.words
    if @words.any?
      @list_content_partial = { partial: 'shared/list_has_word', locals: { list: @list, words: @words } }
    else
      @list_content_partial = { partial: 'shared/list_no_word', locals: { list: @list } }
    end
  end

  def edit
    @words = @list.words
    if @words.any?
      @list_content_partial = { partial: 'shared/list_has_word', locals: { list: @list, words: @words } }
    else
      @list_content_partial = { partial: 'shared/list_no_word', locals: { list: @list } }
    end
  end

  def change_name
    if @list.update(list_params)
      redirect_to lists_path, notice: 'リスト名が更新されました。'
    else
      render :edit
    end
  end    

  def destroy
    @list.destroy
    redirect_to lists_path, notice: 'リストが削除されました。'
  end

  def remove_word
    word = Word.find(params[:word_id])
    @list.words.delete(word)
  
    flash[:notice] = "#{word.term}をリストから削除しました。"
    redirect_to list_path(@list)
  end

  private

  def set_list
    @list = current_user.lists.find(params[:id]) 
  end

  def list_params
    Rails.logger.debug("PARAMS: #{params.inspect}")
    params.require(:list).permit(:name)
  end
end
  