atom_feed do |feed|
  feed.title "#{@section.name} | The Harbour Gazette"
  feed.updated @articles.map(&:updated_at).max || @section.updated_at

  @articles.each do |article|
    feed.entry article, published: article.published_at do |entry|
      entry.title article.headline
      entry.summary article.dek
      article.authors.each do |author|
        entry.author { _1.name author.name }
      end
    end
  end
end
