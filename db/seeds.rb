QuizQuestion.destroy_all
Word.destroy_all

require 'csv'

csv_file_path = Rails.root.join('db/seeds/Word-list.csv')

CSV.foreach(csv_file_path, headers: true) do |row|
  Word.create!(
    term: row['term'],
    definition: row['definition'],
    explanation: row['explanation'],
    example_en: row['example_en'],
    example_jp: row['example_jp'],
    related_videos: row['related_videos'],
    pronunciation_jp: row['pronunciation_jp'],
    pronunciation_en: row['pronunciation_en']
  )
end

puts "Words data loaded successfully from #{csv_file_path}!"
puts "Created #{Word.count} words."

User.find_or_create_by!(email: 'guestuser@noscope.com') do |user|
  user.password = 'NoScope!2025'
  user.password_confirmation = 'NoScope!2025'
  user.nickname = 'ゲストアカウント'
end

puts "Guest user created"
