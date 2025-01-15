module YoutubeHelper
    # YouTube動画を埋め込むためのヘルパーメソッド
    def embed_youtube_video(video_id, options = {})
      width = options[:width] || 560
      height = options[:height] || 315
      title = options[:title] || "YouTube Video"
  
      content_tag(:iframe, nil, 
        width: width, 
        height: height, 
        src: "https://www.youtube.com/embed/#{video_id}",
        title: title,
        frameborder: 0,
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
        allowfullscreen: true
      )
    end
  end
  