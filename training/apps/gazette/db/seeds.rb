news = Section.find_or_create_by!(slug: "news") { _1.name = "News" }
Section.find_or_create_by!(slug: "sport") { _1.name = "Sport" }
Section.find_or_create_by!(slug: "wire") { _1.name = "Wire" }

hana = Author.find_or_create_by!(email: "hana.reti@gazette.example") { _1.name = "Hana Reti" }
Editor.find_or_create_by!(email: "grace@gazette.example") do |editor|
  editor.name = "Grace Whatu"
  editor.access_code = "5521"
  editor.chief = true
end

unless Article.exists?
  article = Article.create!(section: news, headline: "Welcome to the new Gazette", body: "Hello, harbour.")
  article.author_ids_in_order = [hana.id]
  article.publish!
end

Reader.find_or_create_by!(email: "reader@example.com") { _1.display_name = "Reader" }
