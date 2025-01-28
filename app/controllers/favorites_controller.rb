class FavoritesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @favorite_words = current_user.favorite_words.order(:term)
  end
  
  def create
    word = Word.find(params[:word_id])
    current_user.favorites.create(word: word)
    
    respond_to do |format|
      format.turbo_stream do

      youtube_id = if word.related_videos.present?
                     word.related_videos
                   else
                     service = YoutubeService.new
                     video   = service.search_video("counter strike #{word.term}")
                     video&.id&.video_id
                   end
    
      render "words/switch_favorite",locals: { word: word, youtube_video_id: youtube_id }
      end
    end
    
    format.html { redirect_to words_path }
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    word = favorite.word
    favorite.destroy
    @favorite_words = current_user.favorite_words.order(:term)

    respond_to do |format|
      format.turbo_stream do
        youtube_id = if word.related_videos.present?
                       word.related_videos
                     else
                       service = YoutubeService.new
                       video   = service.search_video("counter strike #{word.term}")
                       video&.id&.video_id
                     end
        render "favorites/update_list"
      end
      format.html { redirect_to favorites_path }
    end
  end
end
  