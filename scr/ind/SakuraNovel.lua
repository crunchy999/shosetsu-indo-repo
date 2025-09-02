-- SakuraNovel extension for Shosetsu
-- Language: Indonesian

return {
    id = 10001,
    name = "SakuraNovel",
    baseURL = "https://sakuranovel.id",
    lang = "ind",

    -- Search novel
    search = function(query)
        local url = "https://sakuranovel.id/?s=" .. query
        local doc = GETDocument(url)

        local results = {}
        for novel in doc:select("div.post-title h2 a"):array() do
            table.insert(results, Novel {
                title = novel:text(),
                link = novel:attr("href"),
                imageURL = "", -- opsional: bisa scrape cover
            })
        end
        return results
    end,

    -- Daftar bab
    chapters = function(novelURL)
        local doc = GETDocument(novelURL)
        local results = {}

        for chap in doc:select("div.eplister a"):array() do
            table.insert(results, Chapter {
                title = chap:text(),
                link = chap:attr("href"),
            })
        end

        return results
    end,

    -- Isi bab
    content = function(chapterURL)
        local doc = GETDocument(chapterURL)
        local content = doc:select("div.reading-content"):html()
        return Content {
            text = content
        }
    end
}