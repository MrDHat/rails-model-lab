require "test_helper"

class SectionAtomFeedApiTest < ActionDispatch::IntegrationTest
  test "the feed is built with the atom_feed helper" do
    get section_path(sections(:news), format: :atom)
    doc = Nokogiri::XML(response.body)
    ids = doc.xpath("//a:id", "a" => "http://www.w3.org/2005/Atom").map(&:text)
    assert ids.any?, "no ids in the feed"
    assert ids.all? { _1.start_with?("tag:www.example.com,2005:") },
           "ids aren't the tag: URIs atom_feed writes: #{ids.inspect}"
  end
end
