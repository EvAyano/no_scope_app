class YoutubeService
    def initialize
      @youtube = Google::Apis::YoutubeV3::YouTubeService.new
      @youtube.key = Rails.application.credentials.dig(:youtube, :api_key)
    end
  
    def search_video(query, related_video_id = nil)
      if related_video_id.present?
        return OpenStruct.new(
          id: OpenStruct.new(video_id: related_video_id),
          snippet: OpenStruct.new(
            thumbnails: OpenStruct.new(
              high: OpenStruct.new(url: "https://img.youtube.com/vi/#{related_video_id}/hqdefault.jpg")
            )
          )
        )
      end
  
      #API検索
      Rails.cache.fetch("youtube_search_#{query}", expires_in: 24.hours) do
        response = @youtube.list_searches(
          'snippet',
          q: query,
          type: 'video',
          max_results: 1,
          order: 'relevance'
        )
        response.items.first
      end
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API Error: #{e.message}"
      nil
    end
  end
  