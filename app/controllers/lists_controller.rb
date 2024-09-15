class ListsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_list, only: [:show, :edit, :update, :destroy, :remove_word]
    before_action :check_list_limit, only: [:create]
  
    def index
      @lists = current_user.lists
    end
  
    def new
      @list = current_user.lists.build
    end
  
    def create
      @list = current_user.lists.build(list_params)
      if @list.save
        redirect_to lists_path, notice: 'リストが作成されました。'
      else
        render :new
      end
    end
  
    def show
      @words = @list.words
    end
  
    def edit
      @words = @list.words
    end
  
    def update
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
      params.require(:list).permit(:name)
    end
  
    def check_list_limit
      if current_user.lists.count >= 5
        redirect_to lists_path, alert: 'リストは5つまでしか作成できません。'
      end
    end
  end
  