# Imports a delivery from the news agency's wire: a JSON document with an
# "items" array. Each new item becomes a draft in its section (or in Wire when
# the section is unknown) for an editor to pick up. Items already imported are
# skipped, matched on the agency's guid.
#
#   { "items": [ { "guid": "NZW-2001", "headline": "...", "summary": "...",
#                  "body": "...", "section": "business",
#                  "filed_at": "2026-09-14T06:10:00+12:00",
#                  "keywords": ["port", "shipping"] } ] }
class WireFeed
  FALLBACK_SECTION = "wire"

  def self.import(payload) = new(payload).import

  def initialize(payload)
    @items = JSON.parse(payload).fetch("items")
  end

  def import
    import = WireImport.create!(received_at: Time.current, items_count: @items.size)
    counts = Hash.new(0)

    @items.each do |item|
      if Article.exists?(wire_guid: item["guid"])
        counts[:skipped] += 1
        next
      end

      begin
        create_draft(item)
        counts[:created] += 1
      rescue StandardError => e
        Rails.error.report(e, handled: true)
        counts[:failed] += 1
      end
    end

    import.update!(created_count: counts[:created], skipped_count: counts[:skipped], failed_count: counts[:failed])
    import
  end

  private

  def create_draft(item)
    Article.create!(
      section: section_for(item["section"]),
      headline: item.fetch("headline"),
      dek: item["summary"],
      body: item["body"].to_s,
      wire_guid: item.fetch("guid"),
      status: :draft,
      created_at: filed_at(item),
      tag_list: Array(item["keywords"]).join(",")
    )
  end

  def section_for(slug)
    Section.find_by(slug: slug.to_s) || Section.find_by!(slug: FALLBACK_SECTION)
  end

  def filed_at(item)
    item["filed_at"] ? Time.zone.iso8601(item["filed_at"]) : Time.current
  end
end
