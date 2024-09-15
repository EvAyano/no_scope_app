class Word < ApplicationRecord
    has_many :list_words
    has_many :lists, through: :list_words
end
