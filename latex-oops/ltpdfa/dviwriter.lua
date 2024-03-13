--[[
This is the dvips output driver 
ascii85 from http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/5.3/lascii85.tar.gz
procset for reading verbatim embedded data (xmp, iccprofile) 
'dviwriter.pro'

procset for mapping resources => 'toUnicode.pro'
- define new resource type 'UTFMAPRES'
- defines processfonts proc reading all entries in FontDirectory
 * looks if resource of type UTFMAPRES with FONTNAME exists
 * modifies the font to include /GlyphNames2Unicode in /FontInfo
 * content of GlyphNames2Unicode becomes content of UTFMAPRES
- install 'processfonts' as dvipshook 'start-hook':
userdict begin /start-hook {processfonts} def end'
Example:
-resource (fontname=CMEX10)
/CMEX10MAP 5 dict dup begin
    /summationtext <03FC> def
    /CHARSTRINGS-NAME <UTF16EQUIVALENT> def
   ...
   ...
end def
- define it as resource: /CMEX10 CMEX10MAP /UTFMAPRES defineresource pop

Glyphlist from type1font => t1disasm or t1rawafm or ...
ghostscript can list them to, if ...
existent glyphtounicode texfiles can assist you
TODO:
- generic 'PropertyList' support for BDC (inline dict)
- generic 

--]]
-- from TL2020 kpse_clua_searcher is disabled without --shell-escapes
-- we had to use --lua=axel.lua to save the searchers
if (package.searchers[4] == nil) then
   log("distwriter: Trying to set package.searchers[4] to %s!!!", _G['kpse_clua_searcher'])
   package.searchers[4] = _G['kpse_clua_searcher']
end

local ascii85 = require("ascii85")
local subtype_special  = node.subtype("special") --3
local subtype_savepos  = node.subtype("save_pos") --6
local subtype_latelua  = node.subtype("late_lua") --7
local a_whatsit_node   = node.id("whatsit")
local config           = ltpdfa.config
local anncounter       = 0
local hyphnode         = nil

-- now create hyphnode
hyphnode = node.new(a_whatsit_node, subtype_special)
hyphnode.data = 'ps::markLine'

local function getChildString(arr)
   if (#arr == 0) then
      return nil
   end
   childstring = "[{" .. table.concat(arr, '} {') .. "}]"
   return childstring
end

local function buildAttributes(structelem)
   local nstr = ""
   -- attributes -> /A Entry of struct elem
   if (structelem.attributes) then
      nstr = '/A['
      for k,v in pairs(structelem.attributes) do
         nstr = nstr .. '<</O/' .. k
         for l,w in pairs(structelem.attributes[k]) do
            nstr = nstr .. ' ' .. w
         end
         nstr = nstr .. '>>'
      end
      nstr = nstr .. ']'
   end
   return nstr
end

-- StPNE and friends does not work with ghostscript
-- fills childarray
local function structElems(selem, childarray, head) -- parent
   local tail = node.tail(head)
   local kidsa = {}
   -- write childs
   if (selem.childs) then
      for k,v in pairs(selem.childs) do
         structElems(v, kidsa, head)
      end
   end
   local objname = ""
   local nstr = ""
   if (selem.mcid) then 
      objname = "mcid_" .. selem.startpage .. "_" .. selem.mcid 
      nstr = "ps::[/_objdef{" .. objname .. "} /type/dict/OBJ pdfmark\n"
      nstr = nstr .. "[{" .. objname .. "} <</Type/MCR/Pg{Page" .. selem.startpage .. "}/MCID ".. selem.mcid .. ">>/PUT pdfmark"
      table.insert(childarray, objname)
   elseif (selem.idx) then
      objname = "struct_" .. selem.idx
      local kaname = objname .. "KA"
      nstr = "ps::[/_objdef{" .. objname .. "} /type/dict/OBJ pdfmark\n[/_objdef{" .. kaname .. "} /type/array/OBJ pdfmark\n"
      local kidss = getChildString(kidsa)
      if (kidss == nil) then
         log("Warn: Selem %s/%d has no childs!!!", selem.name, selem.idx)
         kidss = ""
      end
      nstr = nstr .. "[{" .. kaname .. "} 0 " .. kidss .. " /PUTINTERVAL pdfmark\n"
      -- for Link selem we have to add linkObj
      if (selem.relObj) then
         -- to resolve named object we must dereference -> indirect
         nstr = nstr .. "[{" .. kaname .. "} <</Type/OBJR/Obj {" .. selem.relObj .. "} /Pg{Page" .. selem.startpage .. "}>> /APPEND pdfmark\n"
      end
      local parentname = "struct_" .. selem.parent.idx
      local addTxt = ""
      if (selem.altText) then
         addTxt = "\n/Alt (" .. selem.altText .. ")"
      end
      if (selem.neededID) then
         addTxt = addTxt .. "\n/ID (" .. selem.neededID .. ")"
      end
      if (selem.attributes) then
         addTxt = addTxt .. "\n" .. buildAttributes(selem)
      end
      nstr = nstr .. "[{" .. objname .. "} <</Type/StructElem/P{" .. parentname .. "}/S /" .. selem.type .. "/K {" .. kaname .. "}/Pg{Page" .. selem.startpage .. "} /leID (" .. selem.ID .. ") " .. addTxt .. ">>/PUT pdfmark"
      table.insert(childarray, objname)
   end
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   node.insert_after(head, tail, n)
   tail = node.tail(head)
end
--[[
   public/exported
]]--
local function init()
   log("dviwriter init")
   local post = ""
   if config.tounicode then tex.sprint('\\AtBeginDvi{\\special{header=toUnicode.pro}}') end
   tex.sprint('\\AtBeginDvi{\\special{header={dviwriter.pro} post={', post, '}}}')
end
local function addToUnicode(str)
   for fontname in string.gmatch(str,'([^,]+)') do
      tex.sprint('\\AtBeginDvi{\\special{header=', fontname,'.uni}}')
   end
end
local function createStruct(head, curr, sparent)
   log("ps: createStruct")
end

local function beginMC(head, curr, val, mcid, isArtifact, attributes)
   if (config.debug) then
      log("ps:[ /%s <</MCID %d>> /BDC pdfmark", config.bdcs[val], mcid)
   end
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"attr", curr.attr)
   local nstr = nil
   if (isArtifact) then
      nstr = "ps:[/Artifact"
   else
      nstr = "ps:[/" .. config.bdcs[val]
   end
   if (attributes ~= nil) then
      nstr = nstr .. attributes .. " /BDC pdfmark" -- TODO check
   else
      nstr = nstr .. "<</MCID " .. mcid ..">> /BDC pdfmark"
   end
   node.setfield(n,"data", nstr)
   return node.insert_before(head, curr, n)
end

local function endMC(head, curr, val, after)
   n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data","ps:[/EMC pdfmark") --%" .. config.bdcs[val])
   node.setfield(n,"attr", curr.attr)
   if (config.debug) then
      log("ps: /EMC <= %s", val)
   end
   if (after) then
      return node.insert_after(head, curr, n)
   else
      return node.insert_before(head, curr, n)
   end
end

-- create StructParents for current page
local function structParent(head, curr, number)
   if (config.debug) then
      log("ps: structParent %d", number)
   end
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data","ps:[ {ThisPage} <</StructParents " .. number .. "/Tabs/S>> /PUT pdfmark")
   return node.insert_after(head,curr,n)
end

local function closeElem()
   log("ps: closeElem")
end

local function structTree(stree, head)
   -- write root obj
   local rootobj = "struct_" .. stree.root.idx
   local kidsa = {}
   local tail = node.tail(head)
   -- write childs
   for k,v in pairs(stree.root.childs) do
      structElems(v, kidsa, head)
   end
   local childstring = getChildString(kidsa)
   local nstr = "ps::[{Catalog}<</MarkInfo <</Marked true>> >>/PUT pdfmark\n[/_objdef{" .. rootobj .. "} /type/dict/OBJ pdfmark\n"
   nstr = nstr .. "[{" .. rootobj .. "}<</Type/StructTreeRoot/K" .. childstring .. ">>/PUT pdfmark\n"
   nstr = nstr .. "[{Catalog}<</StructTreeRoot {" .. rootobj .. "}>> /PUT pdfmark"
   tail = node.tail(head)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   return node.insert_after(head, tail, n)
end

-- number tree, each key ~ one page
-- entries for each object that is a content item of at least one
-- structure element
-- entries for each content stream containing marked content
-- Kids, Limits, Nums => Kids and Nums contradictionary
local function parentTree(stree, head)
   local tail = node.tail(head)
   local nstr = ""
   local arrstr = ""
   for k,v in ipairs(stree.parenttree) do
      -- no extra indirection for elems with relObj
      local objname = "UNKNOWN"
      if (v.discrete) then
         -- obj on its own
         objname = "{struct_" .. v.idx .."}"
         arrstr = arrstr .. k - 1 .. " " .. objname .. " "
      else
         -- array with child obj
         objname = "{partree_" .. k .."}"
         local carray = ""
         arrstr = arrstr .. k - 1 .. " " .. objname .. " "
         --[[
            • For a content stream containing marked-content sequences that are content
            items, the value is an array of indirect references to the sequences’ parent struc-
            ture elements. The array element corresponding to each sequence is found by
            using the sequence’s marked-content identifier as a zero-based index into the
            array.
            => need an array with entries from 0 bis max mcid on page, unused with null
         --]]
         for l,w in pairs(v) do
            local cobjname = "{struct_" .. w.idx .."}"
            carray = carray .. cobjname .. " " -- array indirect ref to StructureElem
         end
         nstr = "ps::[/_objdef" .. objname .."/type/array /OBJ pdfmark\n"
         nstr = nstr .. "[" .. objname .. 0 .. "[" .. carray .. "]/PUTINTERVAL pdfmark\n"
         local o = node.new(a_whatsit_node, subtype_special)
         node.setfield(o,"data", nstr)
         node.insert_after(head, tail, o)
         tail = node.tail(head)
      end
   end
   -- parenttree 
   nstr = "ps::[/_objdef{parentroot}/type/dict /OBJ pdfmark\n"
   nstr = nstr .. "[{parentroot} <</Nums [" .. arrstr .. "]>>/PUT pdfmark\n"
   nstr = nstr .. "[{struct_0} <</ParentTree{parentroot}/ParentTreeNextKey " .. #stree.parenttree .. ">>/PUT pdfmark"
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   return node.insert_after(head, tail, n)
end

-- also sets required viewerpreferences
local function docLang(lang, head)
   local tail = node.tail(head)
   local nstr = 'ps::[{Catalog} <</Lang('..lang..')>> /PUT pdfmark'
   nstr = nstr .. '[{Catalog} <</ViewerPreferences<</DisplayDocTitle true>> >> /PUT pdfmark'
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   return node.insert_after(head, tail, n)
end

local function roleMap(structtree, head)
   local tail = node.tail(head)
   local nstr = 'ps::[/_objdef{rolemap}/type/dict/OBJ pdfmark\n[{rolemap} <<\n'
   for k,v in pairs(structtree.rolemap) do
      log("\t %s => %s",k, v)
      nstr = nstr .. '/' .. k .. '/' .. v .. '\n'
   end
   nstr = nstr .. '>>/PUT pdfmark\n'
   nstr = nstr .. "[{struct_0} <</RoleMap{rolemap}>>/PUT pdfmark"
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   return node.insert_after(head, tail, n)
end

-- unused
-- start must be inserted before, end after curr
local function savepos(head, curr, index, start)
   local funcname;
   if start then
      funcname = "readPosStart(" .. index .. ")"
   else
      funcname = "readPosEnd(" .. index .. ")"
   end
   local n = node.new(a_whatsit_node, subtype_savepos)
   node.setfield(n,"attr", curr.attr)
   local m = node.new(a_whatsit_node, subtype_latelua)
   node.setfield(m,"attr", curr.attr)
   node.setfield(m,"name", "ltpdfa.readPos")
   node.setfield(m,"data", "ltpdfa.structtree." .. funcname)
   if start then
      local nhead, new = node.insert_before(head, curr, n)
      return node.insert_before(nhead, curr, m)
   else
      local nhead, new = node.insert_after(head, curr, n)
      return node.insert_after(nhead, n, m)
   end
end

local function intent(head)
   local tail = node.tail(head)
   local profile = config.intent.profile
   local filename = kpse.find_file(profile)
   if filename == nil then
      log("Profile %s could not be found!!!", profile)
      return
   else
      log("Using profile %s", filename)
   end
   -- ps: plotfile cannot handle arbitrary binary data ;-( \x04 is converted at least
   -- so we have to use ascii85 or whatever binary save encoding 
   local ascfname = tex.jobname..'.asc' -- filename of ascii85 encoded icc content
   local idate = lfs.attributes(filename, "modification")
   local adate = lfs.attributes(ascfname, "modification") or 0
   local fsize = lfs.attributes(filename, "size")
   -- try to keep ascii chunks < 4096 and divisable by 4 to avoid padding
   -- rowBuffer in .pro is 4096, rowArray must hold fsize
   local steps = math.ceil(fsize / 4096) + 1
   if (idate > adate) then
      local inf = io.open(filename, "r")
      local content = inf:read("*all")
      inf:close()
      local of = io.open(ascfname, "w")
      log("Converting profile with %s", ascii85.version)
      local encoded = ascii85.encode(content)
      of:write(string.sub(encoded,3))
      of:close()
   end
   local val = {}
   table.insert(val, "ps::[/_objdef{iccProfile} /type/stream /OBJ pdfmark")
   table.insert(val, "[{iccProfile} <</N " .. config.intent.components ..">>/PUT pdfmark")
   table.insert(val, "[/_objdef{OutputIntentsInfo} /type/dict /OBJ pdfmark")
   table.insert(val, "[{OutputIntentsInfo} <</Type/OutputIntent /RegistryName(http://www.color.org) /S/GTS_PDFA1 /OutputCondition() /OutputConditionIdentifier(Custom)/Info(" .. config.intent.identifier ..") /DestOutputProfile {iccProfile}>> /PUT pdfmark")
   table.insert(val, "[{Catalog} <</OutputIntents [ {OutputIntentsInfo} ]>> /PUT pdfmark")
   table.insert(val, "plotfileClear/rowArray " .. steps .. " array def\n%%----------ICCSTART----------%%")
   table.insert(val, "isGsPdfwrite{[{iccProfile} //readAscFile 0 () /SubFileDecode filter /PUT pdfmark} {readAscFile pop} ifelse")
   local n = node.new(a_whatsit_node, subtype_special) -- .attr + .data fields
   node.setfield(n,"data", table.concat(val, "\n"))
   head, tail = node.insert_after(head, tail, n)
   local nstr = "ps: plotfile " .. ascfname
   local x = node.new(a_whatsit_node, subtype_special) -- .attr + .data fields
   node.setfield(x,"data", nstr)
   head, tail = node.insert_after(head, tail, x)
   nstr = "ps::[{iccProfile} /CLOSE pdfmark\n"
   nstr = nstr .. "%%----------ICCEND----------%%\n"
   local y = node.new(a_whatsit_node, subtype_special) -- .attr + .data fields
   node.setfield(y,"data", nstr)
   return node.insert_after(head, tail, y)
end

local function docInfo(infoarray, head)
   local tail = node.tail(head)
   local nstr = "ps::["
   for name, val in pairs(infoarray) do
      nstr = nstr .. "/" .. name .. '(' .. val .. ")\n"
   end
   nstr = nstr .. "/DOCINFO pdfmark"
   n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr) -- needs UTF-8
   return node.insert_after(head, tail, n)
end

local function space(head, lastglyph, spacetemplate, spacekern)
   local glyph = lastglyph.node
   if spacetemplate == nil then log("Error: no template node for space!!!") end
   if spacekern == nil then log("Error: no template node for space kerning!!!") end
   local n = node.copy(spacetemplate)
   local m = node.copy(spacekern)
   local head, new = node.insert_after(head, glyph, n)
   return node.insert_after(head, new, m)
end

-- mark a hlist of subtype line
-- pbox = parent box containing curr, curr = box
local function markLine(pbox, curr)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"attr", curr.attr)
   node.setfield(n,"data",'ps:markLine')
   if config.debug then log("markLine\npbox=%s\ncurr=%s\n", pbox, curr) end
   pbox.list = node.insert_before(pbox.list, curr, n)
end

-- softhyphen => AD
local function hyphenation(head, curr)
   if (config.debug) then
      log("ps: /Span<</ActualText <FEFF00AD> >>")
   end
   local n = node.new(a_whatsit_node, subtype_special) --- .attr + mode(setorigin,page,direct) + .data fields
   node.setfield(n,"data",'ps:[/Span<</ActualText <FEFF00AD> >> /BDC pdfmark')
   ----node.attr = curr.attr
   node.insert_before(head, curr, n)
   local m = node.new(a_whatsit_node, subtype_special) --- .attr + .data fields
   node.setfield(m,"data","ps:[/EMC pdfmark")
   if config.debug and config.showspaces and hyphnode then
      node.insert_after(head, curr, m)
      return node.insert_after(head, m, node.copy(hyphnode))
   else
      return node.insert_after(head, curr, m)
   end
end

local function xmpData(filename, head)
   log("insert xmp from %s", filename)
   local fsize = lfs.attributes(filename, "size")
   local steps = math.ceil(fsize / 4096) + 1
   local val = {}
   table.insert(val, "ps::[/_objdef{ltmetadata} /type/stream /OBJ pdfmark")
   table.insert(val, "[{ltmetadata} <</Type/Metadata /Subtype/XML>> /PUT pdfmark")
   -- table.insert(val, "[{Catalog} {ltmetadata} /Metadata pdfmark")
   table.insert(val, "plotfileClear/rowArray " .. steps .. " array def\n%%----------METASTART----------%%")
   table.insert(val, "isGsPdfwrite{[{ltmetadata} //readPlotFile 0 () /SubFileDecode filter /PUT pdfmark} {readPlotFile pop} ifelse")
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", table.concat(val, "\n"))
   local tail = node.tail(head)
   local head, tail = node.insert_after(head, tail, n)
   local nstr = "ps: plotfile " .. filename .."\n"
   local o = node.new(a_whatsit_node, subtype_special)
   node.setfield(o, "data", nstr)
   head, tail = node.insert_after(head, tail, o)
   nstr = "ps::[{ltmetadata} /CLOSE pdfmark\n"
   nstr = nstr .. "%%----------METAEND----------%%\n"
   local p = node.new(a_whatsit_node, subtype_special)
   node.setfield(p, "data", nstr)
   head, tail = node.insert_after(head, tail, p)
   local q = node.new(a_whatsit_node, subtype_special)
    -- distiller does not use this!!!
   -- node.setfield(q, "data", "ps::[{Catalog} {ltmetadata} /Metadata pdfmark")
   -- this inserts a second /Metadata to Catalog :-|
   node.setfield(q, "data", "ps::[{Catalog} <</Metadata {ltmetadata}>> /PUT pdfmark")
   return node.insert_after(head, tail, q)
end

local function addLastLink()
   anncounter = anncounter + 1
   local tmp = 'LinkAnn'.. anncounter
   if config.debug then log("addLastLink %s", tmp) end
   tex.sprint(tmp)
   return tmp
end

-- left TODO
local function IDTree(stree, head)
   return head
end

local writer = {
   init = init,
   addToUnicode = addToUnicode,
   space        = space,
   markLine     = markLine,
   hyphenation  = hyphenation,
   beginMC        = beginMC,
   createStruct   = createStruct,
   closeElem = closeElem,
   endMC        = endMC,
   intent       = intent,
   xmpData      = xmpData,
   docInfo      = docInfo,
   docLang      = docLang,
   structTree   = structTree,
   structParent = structParent,
   parentTree   = parentTree,
   roleMap      = roleMap,
   addLastLink  = addLastLink,
   IDTree       = IDTree,
   -- savepos      = savepos
}
return writer

--[[
[ /_objdef {objname} /type objtype /OBJ pdfmark
dvips specials:
\special{" newpath 0 0 moveto 100 100 lineto 394 0 lineto}
ps: => without surrounding save/restore
ps:: => no positioning

]]--
