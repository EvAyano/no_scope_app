class Contact
  include ActiveModel::Model
  
  attr_accessor :name, :email, :message #仮想モデルなので、手動でgetterとsetterを定義
  
  validates :name, presence: true, length: { maximum: 10 }
  validates :message, presence: true, length: { maximum: 1000 }
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}, allow_blank: true

end
