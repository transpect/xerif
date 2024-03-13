local ltpdfa = require('ltpdfa')
local meta = {
  Author = '',
  Title = '',
  Creator = '',
  Producer = '',
  Keywords = '',
  extract = function ()
    local xmpfile = ltpdfa.metadata.xmphandler.fromFile(ltpdfa.config.metadata.xmpfile)
    local f = io.open(xmpfile, "r")
    local content = f:read("*all")
    f:close()
    if (content:find('<dc:title>')) then
      Title = content:gsub('.*<dc:title>[^<]*<rdf:Alt>[^<]*<rdf:li[^>]*>(.*)</rdf:li>[^<]*</rdf:Alt>[^<]*</dc:title>.*', "%1")
      -- log(">>>" .. meta.Title)
    end
    local authors
    local author = {}
    if (content:find('<dc:creator>')) then
      authors = content:gsub('.*<dc:creator>[^<]*<rdf:Seq>(.*)</rdf:Seq>[^<]*</dc:creator>.*', "%1")
      for k in string.gmatch(authors, "<rdf:li>([^>]+)</rdf:li>") do
        table.insert(author , k)
      end
      Author = table.concat(author, ', ')
    end
  end
}
if type(cocotex) ~= 'table' then
  cocotex = {}
end
cocotex.ally = {
  meta = meta
}
return cocotex.ally
