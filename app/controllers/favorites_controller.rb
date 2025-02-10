class FavoritesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]
  skip_before_action :authenticate_user!, only: [:create]

  def index
    @favorite_words = current_user.favorite_words.order(:term)
  end

  def create
    unless user_signed_in?
      respond_to do |format|
        format.turbo_stream do
          render "favorites/require_login"
        end
        format.html do
          redirect_to new_user_session_path
        end
      end
      return
    end

    word = Word.find(params[:word_id])
    current_user.favorites.create(word: word)

    respond_to do |format|
      format.turbo_stream do
        youtube_id = fetch_youtube_id_for(word)
        render "words/switch_favorite", locals: { word: word, youtube_video_id: youtube_id }
      end
      format.html { redirect_to words_path }
    end
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    word = favorite.word
    favorite.destroy

    youtube_id = fetch_youtube_id_for(word)
    @favorite_words = current_user.favorite_words.order(:term)

    respond_to do |format|
      format.turbo_stream do
        render "favorites/destroy_favorite", locals: { word: word, youtube_video_id: youtube_id }
      end
      format.html { redirect_to favorites_path }
    end
  end

  private

  def fetch_youtube_id_for(word)
    if word.related_videos.present?
      word.related_videos
    else
      service = YoutubeService.new
      video   = service.search_video("counter strike #{word.term}")
      video&.id&.video_id
    end
  end
end
