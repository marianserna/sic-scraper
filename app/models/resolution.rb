class Resolution < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search,
                  against: %i[overview context decision],
                  using: {
                    tsearch: {
                      dictionary: 'spanish'
                    }
                  }

  scope :extracted, -> { where.not(extracted_at: nil) }

  def extracted?
    context.strip.present? && decision.strip.present?
  end
end
