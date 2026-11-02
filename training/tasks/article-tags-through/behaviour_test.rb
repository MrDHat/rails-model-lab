require 'minitest/autorun'
require_relative 'setup'

class EntryLabelsTest < Minitest::Test
  def test_labels_are_a_chainable_relation
    Label.create!(name: 'unused')
    ruby = Label.create!(name: 'ruby')
    rails = Label.create!(name: 'rails')
    entry = Entry.create!(title: 'Post')
    Labeling.create!(entry: entry, label: ruby)
    Labeling.create!(entry: entry, label: rails)
    assert entry.labels.where(name: 'ruby').exists?
    refute entry.labels.where(name: 'unused').exists?
    assert_equal %w[rails ruby], entry.labels.order(:name).pluck(:name)
  end
end
