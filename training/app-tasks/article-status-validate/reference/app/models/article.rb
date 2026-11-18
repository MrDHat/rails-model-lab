class Article < ApplicationRecord
  class InvalidTransition < StandardError; end

  belongs_to :section
  has_many :authorships, dependent: :delete_all
  has_many :authors, through: :authorships
  has_many :taggings, dependent: :delete_all
  has_many :tags, through: :taggings
  has_many :comments, dependent: :delete_all
  has_many :corrections, dependent: :delete_all

  # draft: being written; ready: subbed and waiting for publish_at (or for an
  # editor to press Publish); published: on the site; spiked: killed.
  enum :status, { draft: 0, ready: 1, published: 2, spiked: 3 }, validate: true

  validates :headline, presence: true, length: { maximum: 140 }
  validates :slug, presence: true, uniqueness: true
  validates :dek, length: { maximum: 280 }
  validates :wire_guid, uniqueness: true, allow_nil: true

  before_validation :assign_slug, on: :create

  scope :live, -> { published.where(published_at: ..Time.current) }
  scope :newest_first, -> { order(published_at: :desc, id: :desc) }
  scope :due, ->(now = Time.current) { ready.where(publish_at: ..now) }
  scope :tagged, ->(name) { joins(:tags).where(tags: { name: name }) }
  scope :search, lambda { |query|
    pattern = "%#{sanitize_sql_like(query.to_s.strip)}%"
    where("articles.headline LIKE :p OR articles.dek LIKE :p OR articles.body LIKE :p", p: pattern)
  }

  def to_param = slug

  def byline
    return if authors.empty?

    "By " + authors.map(&:name).join(", ")
  end

  def tag_list = tags.map(&:name).join(", ")

  def tag_list=(text)
    names = text.to_s.split(",").map { _1.strip.downcase }.compact_blank.uniq
    self.tags = names.map { Tag.find_or_create_by!(name: _1) }
  end

  def author_ids_in_order=(ids)
    ids = Array(ids).compact_blank.map(&:to_i).uniq
    authorships.where.not(author_id: ids).delete_all
    ids.each_with_index do |author_id, position|
      authorships.find_or_initialize_by(author_id: author_id).update!(position: position)
    end
    authors.reset
  end

  def live? = published? && published_at.present? && published_at <= Time.current

  def publish!(at: Time.current)
    raise InvalidTransition, "Spiked stories can't be published." if spiked?
    raise InvalidTransition, "Add a byline before publishing." if authors.empty?

    update!(status: :published, published_at: published_at || at, publish_at: nil)
  end

  def schedule!(time)
    raise InvalidTransition, "Only drafts and ready stories can be scheduled." unless draft? || ready?
    raise InvalidTransition, "Pick a time in the future." if time.blank? || time <= Time.current

    update!(status: :ready, publish_at: time)
  end

  def unpublish!
    raise InvalidTransition, "Only published stories can be unpublished." unless published?

    update!(status: :draft, publish_at: nil)
  end

  def spike!
    raise InvalidTransition, "Published stories must be unpublished first." if published?

    update!(status: :spiked, publish_at: nil)
  end

  # Other stories to read next, shown under the article.
  def related(limit = 4)
    section.articles.live.newest_first.limit(limit)
  end

  def record_view!
    update_column(:views_count, views_count + 1)
  end

  def reading_minutes = [(body.split.size / 230.0).ceil, 1].max

  def comments_open? = comments_enabled? && Setting[:comments_open]

  def as_api
    {
      id: id,
      slug: slug,
      headline: headline,
      dek: dek,
      byline: byline,
      section: section.name,
      section_slug: section.slug,
      tags: tags.map(&:name),
      published_at: published_at&.iso8601,
      updated_at: updated_at.iso8601,
      reading_minutes: reading_minutes,
      comments_count: comments_count
    }
  end

  private

  def assign_slug
    self.slug = headline.to_s.downcase.strip.tr(" ", "-") if slug.blank?
  end
end
