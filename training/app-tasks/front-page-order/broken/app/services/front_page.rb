# What the home page shows: the lead story, then each section with its
# newest stories.
class FrontPage
  Block = Data.define(:section, :articles)

  def initialize(per_section: 3)
    @per_section = per_section
  end

  def lead = Article.live.newest_first.first

  # The chief editor's order from the settings.
  def sections
    order = Setting[:front_page_order]
    order.empty? ? Section.order(:name) : Section.in_order_of(:slug, order).order(:name)
  end

  def blocks
    sections.filter_map do |section|
      articles = section.latest(@per_section).includes(:authors).to_a - [lead]
      Block.new(section:, articles:) if articles.any?
    end
  end
end
