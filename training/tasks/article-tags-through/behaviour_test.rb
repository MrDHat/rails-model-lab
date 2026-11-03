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

  def test_each_entry_sees_only_its_own_labels
    go = Label.create!(name: 'go')
    sql = Label.create!(name: 'sql')
    first = Entry.create!(title: 'First')
    second = Entry.create!(title: 'Second')
    Labeling.create!(entry: first, label: go)
    Labeling.create!(entry: second, label: sql)
    assert_equal ['go'], first.labels.pluck(:name)
    assert_equal ['sql'], second.labels.pluck(:name)
    assert_empty Entry.create!(title: 'Bare').labels.to_a
  end
end
