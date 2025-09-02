return {
  id = "sakuranovel",
  name = "SakuraNovel",
  baseUrl = "https://sakuranovel.id",

  -- Cari novel
  find = function(self, query, page)
    return {}
  end,

  -- Novel terbaru
  latest = function(self, page)
    return {}
  end,

  -- Ambil daftar bab
  chapters = function(self, novelId)
    return {}
  end,

  -- Ambil isi bab
  content = function(self, chapterId)
    return "Belum diimplementasikan"
  end
}