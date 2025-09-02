-- SakuraNovel Extension for Shosetsu
-- Language: Indonesian

return {
  id = 10001,
  name = "SakuraNovel",
  baseURL = "https://sakuranovel.id",
  lang = "ind",
  version = "1.0.0",
  libVer = "1.0.0",

  -- Search function
  search = function(query)
    local url = "https://sakuranovel.id/?s=" .. query
    local doc = GETDocument(url)
    local results = {}
    for novel in doc:select("h2.post-title a"):array() do
      table.insert(results, Novel {
        title = novel:text(),
        link = novel:attr("href")
      })
    end
    return results
  end,

  -- Get chapters
  chapters = function(novelURL)
    local doc = GETDocument(novelURL)
    local results = {}
    for chap in doc:select("div.eplister a"):array() do
      table.insert(results, Chapter {
        title = chap:text(),
        link = chap:attr("href")
      })
    end
    return results
  end,

  -- Fetch content
  content = function(chapterURL)
    local doc = GETDocument(chapterURL)
    return Content {
      text = doc:select("div.reading-content"):html()
    }
  end
}