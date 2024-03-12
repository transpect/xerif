--[[
This is the main entry point for tex
--]]
-- variables

-- attribute number holding type, start with 100 / sync with structnum in tagger
local typeattr        = luatexbase.new_attribute('typeattr')
-- attribute number holding number of parent (means index in stree.structarray)
local parentattr      = luatexbase.new_attribute('parentattr')
-- attribute number holding fakespace + hyphtype
local spaceattr       = luatexbase.new_attribute('spaceattr')
-- know how many pages were processed
local lastShippedOut = 0

-- tables
local config = {
   structnumstart = 100,
   autoclose   = {}, -- table of structs and their parents (section => document)
   artifact    = {}, -- treat as artifact
   bdcs        = {}, -- types of structelem, filled from tagger or static config
   metadata    = {},
   tounicode   = "",
   -- package options
   final       = true,
   dospaces    = false,
   showspaces  = false,
   dohyphens   = false,
   headnums    = false,
   debug       = false,
   nodetree    = false,
   driver      = "dvips",
   ltpdfCatcode = nil,
   xmpfile     = nil,
}
config.bdcs['autopara'] = 10
config.bdcs[10] = 'autopara'
if luatexbase.registernumber then
   config.ltpdfCatcode = luatexbase.registernumber("catcodetable@latex")
else
   config.ltpdfCatcode = luatexbase.catcodetables.CatcodeTableLaTeX
end

--[[
   These are the private functions
--]]
function log( ... )
   texio.write_nl(string.format(...))
end
function dumpArray(P, recurse, level)
   local level = level or 1
   local indent = string.rep("  ", level)
   log("%sdump of %s",indent , P)
   for k,v in pairs(P) do
      log("%s%s => %s",indent, k, v)
      if (type(v) == 'table' and recurse) then 
         dumpArray(v, recurse, level + 1)
      end
   end
end

-- helper work backwards up and build the hierarchy
local function autoFinalize(key, val)
   -- put type in config.autoclose v.Type
   -- v.Type key => Child, Parent, 
   local reversed = {}
   local atype = {}
   local level = 0
   for k,v in pairs(config.autoclose) do
      if (v.Type == val.Type) then 
         reversed[v.Child] = k
         level = level + 1
      end
   end
   for k,v in pairs(config.autoclose) do
      atype[k] = {}
      config.autoclose[k]['Self'] = k
      atype[k]['Parent'] = config.autoclose[reversed[k]]
      atype[k]['Child'] = config.autoclose[v.Child]
      atype[k]['Self'] = k
   end
   local parent = atype[key]
   repeat
      parent['Level'] = level
      config.autoclose[parent.Self]['Level'] = level
      level = level - 1
      parent = parent['Parent'] or {}
      parent = atype[parent.Self]
   until (parent == nil)
   config.autoclose[val.Type] = atype
end
-- search autoclose array and start at entries with none
local function configAutoclose()
   for k,v in pairs(config.autoclose) do
      if (v.Child == 'none') then
         autoFinalize(k,v)
      end
   end
end
--[[
   These are public functions
--]]
-- very first initialization at loading of style
local function init()
   if config.final == false then
      return
   end
   if config.debug == "true" then
      config.debug = true
   end
   if config.driver == "dvips" then
      --- write pdfmark into dvi
      ltpdfa.odriver = require("dviwriter")
   elseif config.driver == "distps" then
      ltpdfa.odriver = require("distwriter")
   elseif config.driver == "pdftex" then
      --- write with pdftex methods
      ltpdfa.odriver = require("pdfwriter")
   elseif config.driver == "dummy" then
      --- write with pdftex methods
      ltpdfa.odriver = require("dummywriter")
   end
   ltpdfa.odriver.init()
   ltpdfa.structtree.setWriter(ltpdfa.odriver)
   if config.dospaces then
      ltpdfa.spaceprocessor = require("spaces")
      if config.showspaces then
         ltpdfa.spaceprocessor.setDebug(true)
      end
      config.dohyphens = true
   end
   -- debug
   if config.debug then
      log("dump of config (init):")
      dumpArray(config)
      if (config.nodetree == true) then
         nodetree = require("nodetree/nodetree")
         nodetree.set_option('engine', 'lualatex')
         if (tex.luatexversion < 112) then nodetree.set_default_options() end
      end
      -- if (config.doparas) then 
      --    luatexbase.add_to_callback("post_linebreak_filter", ltpdfa.structtree.markPara, "markPara")
      -- end
   end
end
local function addToUnicode(str)
   if (config.tounicode ~= '') then
      config.tounicode = config.tounicode .. "," .. str
   else
      config.tounicode = str
   end
end
-- add something to configtable
local function addToConfig(key, value, enc)
   local enc = enc or false
   for p in value:gmatch('([^;]+)') do
      local k = p:find('=')
      local v = p:sub(k+1)
      if (v == '' or v == '""') then v = nil end
      if v == 'true' then v = true end
      if v == 'false' then v = false end
      -- {key:value} => table
      if (v and v:sub(1,1) == '{') then
         local new = {}
         for ka, va in v:gmatch('{([^:]+):([^}]*)}') do
            if va == 'true' then va = true end
            if va == 'false' then va = false end
            new[ka] = va
         end
         v = new
      end
      k = p:sub(1,k-1)
      if (config[key]) then
         config[key][k] = v
      else
         config[key] = {}
         config[key][k] = v
      end
   end
end
local function setDocInfo(key, val, enc)
   local enc = enc or 'utf-8'
   if enc == '' then enc = 'utf-8' end
   if (key == 'conformance') then
      for p in val:gmatch('([^;]+)') do
         local k = p:find('=')
         local v = p:sub(k+1)
         k = p:sub(1,k-1)
         if (config.metadata[key] == nil) then config.metadata[key] = {}; config.metadata[key][2] = enc end
         config.metadata[key][k] = v
      end
   else
      config.metadata[key] = {val, enc}
   end
end
local function getPageNum()
   tex.print(ltpdfa.lastShippedOut)
   ltpdfa.structtree.closePosFile()
end
local function getAttribute(name)
   tex.print(luatexbase.attributes[name])
end
local function beginDocument(page)
   if config.tounicode and string.len(config.tounicode) > 0 then
      log("ZZZZZ %s", config.tounicode)
      ltpdfa.odriver.addToUnicode(config.tounicode) -- ????? want this in nodelist without attributes
   end
   -- we overrode \begin
   -- in (\begin)\document is an \endgroup first so we can start struct but attribute does not stick
   -- lets do it here for \begin{document}
   -- leads from 21 attribute to 57 attribute in words of node memory still in use
   tex.setattribute(ltpdfa.typeattr, config.structnumstart)
   tex.setattribute(ltpdfa.parentattr, 1)
   if (tonumber(page)) then
      ltpdfa.lastpage = tonumber(page)
   else
      ltpdfa.lastpage = -1
   end
   -- postprocess autoclose config
   configAutoclose()
   if config.debug == true then
      log("debug dump of ltpdfa.config:")
      dumpArray(ltpdfa.config, true)
      log("ltpdfa.beginDocument (lastpage=%s/%s)", page, ltpdfa.lastpage)
      pdf.setcompresslevel(0)
      pdf.setobjcompresslevel(0)
      log("voffset=%.2fbp\npagebottomoffset=%.2fbp\npageheight=%.2fbp\npagetopoffset=%.2fbp\n", ltpdfa.structtree.sptobp(tex.voffset), ltpdfa.structtree.sptobp(tex.pagebottomoffset), ltpdfa.structtree.sptobp(tex.pageheight), ltpdfa.structtree.sptobp(tex.pagetopoffset))
   else
      log("dump of ltpdfa.config:")
      dumpArray(ltpdfa.config)
   end
   -- later initialization if too early in init
   if config.dospaces then
      ltpdfa.spaceprocessor = require("spaces")
      if config.showspaces then
         ltpdfa.spaceprocessor.setDebug(true)
      else
         ltpdfa.spaceprocessor.createDummyFont()
      end
      config.dohyphens = true
   end
   ltpdfa.structtree.readPosFile()
   --log("READ POSFILE %s", f)
end
local function endDocument()
   if config.debug then
      log("ltpdfa.endDocument lastpage=%d for %s", ltpdfa.lastpage, tex.jobname)
   end
   -- try to autoclose
   -- TODO CHECK ltpdfa.tagger.autoClose('document', nil, true)
end

-- public part
ltpdfa = {}
-- configure table and return
-- vars
ltpdfa.typeattr = typeattr
ltpdfa.parentattr = parentattr
ltpdfa.spaceattr  = spaceattr
ltpdfa.lastShippedOut = lastShippedOut
-- tables
ltpdfa.config = config
-- sub modules
ltpdfa.structtree = require("structtree")
ltpdfa.tagger = require("tagger")
ltpdfa.metadata = require("metadata")
-- funcs
ltpdfa.init = init
ltpdfa.addToConfig = addToConfig
ltpdfa.beginDocument = beginDocument
ltpdfa.endDocument = endDocument
ltpdfa.getPageNum = getPageNum
ltpdfa.getAttribute = getAttribute
ltpdfa.addToUnicode = addToUnicode
ltpdfa.setDocInfo   = setDocInfo
--
ltpdfa.pageprocessor = ltpdfa.structtree.pageprocessor -- called from \AtBeginShipout
return ltpdfa
