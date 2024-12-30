class Word < ApplicationRecord
    validates :term, presence: true
    validates :definition, presence: true
end
