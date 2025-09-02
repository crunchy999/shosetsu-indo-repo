-- sakuranovel.lua
-- Extension Shosetsu untuk sakuranovel.id
-- Author: didesain untuk repo crunchy999

local BaseURL = "https://sakuranovel.id"

local function trim(s)
  if not s then return s end
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function absUrl(href)
  if not href then return nil end
  if href:match("^https?://") then return href end
  local base = BaseURL:gsub("/$", "")
  if href:sub(1,1) == "/" then
    return base .. href
  else
    return base .. "/" .. href
  end
end

-- coba beberapa selector sampai dapat hasil non-empty
local function selectFirstNonEmpty(doc, selectors)
  for _, sel in ipairs(selectors) do
    local ok, nodes = pcall(function() return doc:select(sel) end)
    if ok and nodes then
      -- coba iterator, lihat apakah ada elemen nyata
      local found = false
      for _ in nodes:iterator() do
        found = true
        break
      end
      if found then
        return nodes
      end
    end
  end
  return nil
end

return {
  id = "sakuranovel",
  name = "SakuraNovel",
  baseUrl = BaseURL,
  version = 1,
  langs = {"id"},

  -- find/search(query, page) -> return array of Novel(title, url, author)
  find = function(self, query, page)
    page = page or 1
    local q = tostring(query):gsub(" ", "+")
    local url = BaseURL .. "/?s=" .. q
    if tonumber(page) and tonumber(page) > 1 then
      url = url .. "&paged=" .. tostring(page)
    end

    local doc = GETDocument(url)
    local results = {}

    local selectors = {
      ".post-title a",
      "h2.entry-title a",
      ".entry-title a",
      ".post h2 a",
      ".post .title a",
      ".article .title a",
      ".post > a"
    }

    for _, sel in ipairs(selectors) do
      for node in doc:select(sel):iterator() do
        local title = trim(node:text() or "")
        local link = node:attr("href")
        if title ~= "" and link then
          results[#results+1] = Novel(title, absUrl(link), "")
        end
      end
      if #results > 0 then break end
    end

    return results
  end,

  -- latest(page) -> latest posts
  latest = function(self, page)
    page = page or 1
    local url = (page and tonumber(page) and tonumber(page) > 1) and (BaseURL .. "/page/" .. tostring(page) .. "/") or BaseURL
    local doc = GETDocument(url)
    local results = {}

    local selectors = {
      ".post-title a",
      "h2.entry-title a",
      ".entry-title a",
      ".home .post h2 a"
    }

    for _, sel in ipairs(selectors) do
      for node in doc:select(sel):iterator() do
        local title = trim(node:text() or "")
        local link = node:attr("href")
        if title ~= "" and link then
          results[#results+1] = Novel(title, absUrl(link), "")
        end
      end
      if #results > 0 then break end
    end

    return results
  end,

  -- chapters(novelUrl) -> return array of Chapter(title, url)
  chapters = function(self, novelUrl)
    local doc = GETDocument(novelUrl)
    local chapters = {}

    local selectors = {
      ".eplister ul li a",
      ".post .eplister a",
      ".chapter-list a",
      ".chapters-list a",
      ".entry-content a",
      ".post-content a",
      ".wp-manga-chapter a",
      ".chapters a"
    }

    for _, sel in ipairs(selectors) do
      for node in doc:select(sel):iterator() do
        local title = trim(node:text() or "")
        local link = node:attr("href")
        if link and title ~= "" then
          chapters[#chapters+1] = Chapter(title, absUrl(link))
        end
      end
      if #chapters > 0 then break end
    end

    -- jika masih kosong, coba cari link di "div.entry"
    if #chapters == 0 then
      for node in doc:select("a"):iterator() do
        local link = node:attr("href")
        local title = trim(node:text() or "")
        if link and title ~= "" and link:match("/chapter") then
          chapters[#chapters+1] = Chapter(title, absUrl(link))
        end
      end
    end

    return chapters
  end,

  -- content(chapterUrl) -> return HTML string of chapter content
  content = function(self, chapterUrl)
    local doc = GETDocument(chapterUrl)
    local selectors = {
      "div.entry-content",
      ".entry-content",
      "div.post-content",
      ".post-content",
      ".chapter-content",
      ".chapter",
      ".entry"
    }

    local html = nil
    for _, sel in ipairs(selectors) do
      local ok, node = pcall(function() return doc:select(sel) end)
      if ok and node then
        -- node could be a nodeset; try :html()
        local ok2, h = pcall(function() return node:html() end)
        if ok2 and h and h:match("%S") then
          html = h
          break
        end
      end
    end

    -- fallback: whole article or body
    if not html then
      local ok3, h3 = pcall(function() return doc:select("article"):html() end)
      if ok3 and h3 and h3:match("%S") then
        html = h3
      else
        local ok4, h4 = pcall(function() return doc:body():html() end)
        if ok4 and h4 then html = h4 end
      end
    end

    if not html then
      return "Isi bab tidak ditemukan."
    end

    -- bersihkan script/style
    html = html:gsub("<script.->.-</script>", "")
    html = html:gsub("<style.->.-</style>", "")

    -- beberapa situs menaruh 'Baca Juga' / nav di dalam entry-content -> buang baris pendek yang mengandung kata umum
    html = html:gsub("<div[^>]->%s*[Bb]aca [Jj]uga.-</div>", "")

    return html
  end
}