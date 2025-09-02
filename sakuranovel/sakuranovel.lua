-- Sakuranovel Shosetsu Extension
-- Author: crunchy999

local BaseURL = "https://sakuranovel.id"

-- Fungsi: Cari novel
function Search(query)
    local url = BaseURL .. "/?s=" .. query:gsub(" ", "+")
    local doc = GETDocument(url)
    local results = {}
    
    for item in doc:select(".post-title a"):iterator() do
        local title = item:text()
        local link = item:attr("href")
        results[#results+1] = Novel(title, link, "")
    end
    
    return results
end

-- Fungsi: Ambil daftar chapter
function GetChapters(novelUrl)
    local doc = GETDocument(novelUrl)
    local chapters = {}
    
    for item in doc:select(".eplister ul li a"):iterator() do
        local title = item:text()
        local link = item:attr("href")
        chapters[#chapters+1] = Chapter(title, link)
    end
    
    return chapters
end

-- Fungsi: Ambil isi chapter
function GetContent(chapterUrl)
    local doc = GETDocument(chapterUrl)
    local content = doc:select(".entry-content"):html()
    return content
end