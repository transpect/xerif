--[[
This is the dvi + dvips + distiller output driver
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
-- we had to use --lua=ltload.lua to save the searchers

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
local strfile          = tex.jobname .. '.pro'
local stroutfile       = nil
local anncounter       = 0
local annsubcounter    = 0
local hyphnode = nil

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

local function buildAttributes(selem)
   local nstr = ""
   if (selem.attributes) then
      for k,v in pairs(selem.attributes) do
         nstr = nstr .. '[/_objdef{attr_' .. selem.idx .. '_' .. k ..'}/type/dict/OBJ pdfmark\n'
         nstr = nstr .. '[{attr_' .. selem.idx .. '_' .. k .. '} '
         nstr = nstr .. '<</O/' .. k
         for l,w in pairs(selem.attributes[k]) do
            nstr = nstr .. ' ' .. w
         end
         nstr = nstr .. '>>/PUT pdfmark\n'
         nstr = nstr .. '[/Obj{attr_'.. selem.idx .. '_' .. k .. '}/StAttr pdfmark\n'
      end
      return nstr
   end
   return ""
end

local function escapePSString(str)
   str = str:gsub('%%', '\\%%')
   return str
end

local function structElems(idx, selem)
   -- write/push Element
   local nstr = '[/Type/StructElem/Subtype/'  .. selem.type ..  "/_objdef{" .. selem.ID .. "}/At " .. idx
   local addTxt = " "
   if (selem.neededID) then
      addTxt = addTxt .. "/ID(" .. selem.neededID .. ")"
   end
   if (selem.altText) then
      -- escape postscript special chars selem.altText
      local tmp = escapePSString(selem.altText)
      addTxt = "\n/Alt (" .. tmp .. ")"
   end
   if (selem.Lang) then
      addTxt = "\n/Lang(" .. selem.Lang .. ")"
   end
   stroutfile:write(nstr .. addTxt .. "/StPNE pdfmark\n")
   -- add attributes
   if (selem.attributes) then
      stroutfile:write(buildAttributes(selem))
   end
   -- write childs
   if (selem.childs) then
      for k,v in pairs(selem.childs) do
         if (v.mcid == nil) then
            structElems(k, v)
         end
      end
   end
   stroutfile:write('[/Popped/' .. selem.ID .. '/StPop pdfmark\n')
   -- local objname = ""
   -- if (structelem.mcid) then 
   --    objname = "mcid_" .. structelem.startpage .. "_" .. structelem.mcid 
   --    nstr = "ps::[/_objdef{" .. objname .. "} /type/dict/OBJ pdfmark\n"
   --    nstr = nstr .. "[{" .. objname .. "} <</Type/MCR/Pg{Page" .. structelem.startpage .. "}/MCID ".. structelem.mcid .. ">>/PUT pdfmark"
   --    table.insert(childarray, objname)
   --    -- better this way ??? table.insert(childarr, structelem.mcid)
   -- elseif (structelem.idx) then
   --    objname = "struct_" .. structelem.idx
   --    local childstring = getChildString(newarr)
   --    if (childstring == nil) then
   --       log("Warn: StructElem %s/%d has no childs!!!", structelem.name, structelem.idx)
   --       childstring = ""
   --    end
   --    -- for Link structelem we have to add linkObj
   --    if (structelem.relObj) then
   --       --local lobj = pdf.immediateobj("<<\n/Type /OBJR\n/Obj " .. structelem.relObj .. " 0 R\n/Pg " .. pdf.pageref(structelem.startpage) .. " 0 R\n>>")
   --       --childstring = childstring .. " " .. lobj .. " 0 R"
   --       local lobjstr = " <<\n/Type /OBJR\n/Obj " .. structelem.relObj .. " 0 R\n/Pg " .. pdf.pageref(structelem.startpage) .. " 0 R\n>> "
   --       childstring = childstring .. lobjstr
   --    end
   --    local parentname = "struct_" .. structelem.parent.idx
   --    local addTxt = ""
   --    if (structelem.altText) then
   --       addTxt = "\n/Alt (" .. structelem.altText .. ")"
   --    end
   --    nstr = "ps::[/_objdef{" .. objname .. "} /type/dict/OBJ pdfmark\n"
   --    nstr = nstr .. "[{" .. objname .. "} <</Type/StructElem/P{" .. parentname .. "}/S /" .. structelem.type .. "/K " .. childstring .. "/Pg{Page" .. structelem.startpage .. "} /leID (" .. structelem.ID .. ") " .. addTxt .. ">>/PUT pdfmark"
   --    table.insert(childarray, objname)
   -- end
   -- local n = node.new(a_whatsit_node, subtype_special)
   -- node.setfield(n,"data", nstr)
   -- node.insert_after(head, tail, n)
   -- tail = node.tail(head)
end

-- reads texfile with pdfmark commands for (pre-)creating StructElems
local function inputStrFile()
   tex.sprint('\\AtBeginDvi{\\special{header={' .. strfile .. '}}}')
end

--[[
   public/exported
]]--
local function init()
   log("distwriter init")
   local post = ""
   if config.tounicode then tex.sprint('\\AtBeginDvi{\\special{header=toUnicode.pro}}') end
   tex.sprint('\\AtBeginDvi{\\special{header={dviwriter.pro} post={', post, '}}}')
   tex.sprint('\\ifnum\\outputmode=0\\relax\\else\\PackageError{ltpdfa}{No dvi output selected}{You have to use outputmode=0}\\stop\\fi')
   inputStrFile()
end
local function addToUnicode(str)
   for fontname in string.gmatch(str,'([^,]+)') do
      tex.sprint('\\AtBeginDvi{\\special{header=', fontname,'.uni}}')
   end
end
local function createStruct(head, curr, sparent)
   if config.debug then log("\tps: createStruct") end
end

local function beginMC(head, curr, attrval, mcid, isArtifact, attributes, sparent, at)
   if (config.debug) then
      log("ps:[ /T/%s/P<</MCID %d>> /StBDC pdfmark", config.bdcs[attrval], mcid)
   end
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"attr", curr.attr)
   local nstr = nil
   if (isArtifact) then
      nstr = "ps:[/Artifact"
      if (attributes ~= nil) then
         nstr = nstr .. attributes .. "/BDC pdfmark"
      end
   else
      local selem = sparent.actpara or sparent
      nstr = "ps:[/E{" .. selem.ID .. "}/StPush pdfmark\n[/T/" .. config.bdcs[attrval]
      if (attributes ~= nil) then
         nstr = nstr .. '/P' .. attributes .. ">>/At " .. at-1 .. "/StBDC pdfmark" -- TODO check
      else
         nstr = nstr .. "/P<</MCID " .. mcid ..">>/At " .. at-1 .. "/StBDC pdfmark"
      end
   end
   node.setfield(n,"data", nstr)
   return node.insert_before(head, curr, n)
end

-- val = typeattr
local function endMC(head, curr, attr, after)
   local n = node.new(a_whatsit_node, subtype_special)
   -- when to pop ???
   if (config.artifact and config.artifact[config.bdcs[attr]]) then
      node.setfield(n,"data","ps:[/EMC pdfmark")
   else
      node.setfield(n,"data","ps:[/EMC pdfmark\n[/FromPage/" .. config.bdcs[attr] .. "/StPop pdfmark")
   end
   node.setfield(n,"attr", curr.attr)
   if (config.debug) then
      log("ps: /EMC <= %s", attr)
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
   node.setfield(n,"data","ps:[ {ThisPage} <</Tabs/S>> /PUT pdfmark")
   return node.insert_after(head,curr,n)
end

local function closeElem(selem)
   if config.debug then log("ps: closeElem") end
end

local function structTree(stree, head)
   local nstr = "ps::[{Catalog}<</MarkInfo <</Marked true>> >>/PUT pdfmark"
   local tail = node.tail(head)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   local head, tail = node.insert_after(head, tail, n)
   -- overwrite strfile with actual values
   stroutfile = io.open(strfile, 'w+')
   -- write structs
   for k,v in pairs(stree.root.childs) do
      structElems(k, v)
   end
   stroutfile:close()
   return head
end

-- number tree, each key ~ one page
-- entries for each object that is a content item of at least one
-- structure element
-- entries for each content stream containing marked content
-- Kids, Limits, Nums => Kids and Nums contradictionary
local function parentTree(stree, head)
   -- maintained and created by acrobat distiller 
   return head
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
   local nstr = "ps:["
   for k,v in pairs(structtree.rolemap) do
      log("\t %s => %s",k, v)
      nstr = nstr .. '/' .. k .. '/' .. v .. '\n'
   end
   nstr = nstr .. '/StRoleMap pdfmark\n'
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr)
   node.insert_after(head, tail, n)
   return head
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
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", nstr) -- needs UTF-8
   return node.insert_after(head, tail, n)
end

local function space(head, lastglyph, spacetemplate, spacekern)
   local glyph = lastglyph.node
   if spacetemplate == nil then log("Error: no template node for space!!!") end
   if spacekern == nil then log("Error: no template node for space kerning!!!") end
   local n = node.copy(spacetemplate)
   local m = node.copy(spacekern)
   -- attr
   node.setfield(n,"attr", glyph.attr)
   node.setfield(m,"attr", glyph.attr)
   -- log("FONT FOR SPACE %s", lastglyph.node.font)
   -- n.font = lastglyph.node.font
   local head, new = node.insert_after(head, glyph, n)
   return node.insert_after(head, new, m)
end

-- mark a hlist of subtype line
-- pbox = parent box containing curr, curr = box
local function markLine(pbox, curr)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"attr", curr.attr)
   node.setfield(n,"data",'ps:markLine')
   log("writer markLine\npbox=%s\ncurr=%s\n", pbox, curr)
   pbox.list = node.insert_before(pbox.list, curr, n)
end

local function markPara(head, tail, groupcode)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"attr", head.attr)
   node.setfield(n,"data",'ps:markPara%groupcode=' .. groupcode)
   log("writer markPara")
   return node.insert_before(head, head, n)
end

-- softhyphen => AD
local function hyphenation(head, curr)
   if (config.debug) then
      log("ps: /Span<</ActualText <FEFF00AD> >>")
   end
   local n = node.new(a_whatsit_node, subtype_special) --- .attr + mode(setorigin,page,direct) + .data fields
   node.setfield(n,"data",'ps:[/Span<</ActualText <FEFF00AD> >> /BDC pdfmark')
   -- TODO
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

-- local function xmpData(filename, head)
--    log("insert xmp from %s", filename)
--    --local fsize = lfs.attributes(filename, "size")
--    --local steps = math.ceil(fsize / 4096) + 1
--    local val = {}
--    table.insert(val, "ps::[begin]%%---------- XMPMARKSTART ----------%%")
--    table.insert(val, "ps::[/NamespacePush pdfmark")
--    table.insert(val, "ps::[ /_objdef {xmpMetadata} /type /stream /OBJ pdfmark")
--    table.insert(val, "ps::[ {xmpMetadata} currentfile 0 (%%---------- xmpmarkend ----------) /SubFileDecode filter /PUT pdfmark")
--    --table.insert(val, "ps: plotfile " .. filename)
--    table.insert(val, "ps: plotfile " .. "crossmark.xml")
--    table.insert(val, "ps::%%---------- xmpmarkend ----------")
--    table.insert(val, "ps::[ {xmpMetadata} << /Type /Metadata /Subtype /XML >> /PUT pdfmark")
--    table.insert(val, "ps::[ {Catalog} << /Metadata {xmpMetadata} >> /PUT pdfmark")
--    table.insert(val, "ps::[/NamespacePop pdfmark")
--    table.insert(val, "ps::[end]%%---------- XMPMARKEND ----------")
--    local tail
--    tail = node.tail(head)
--    for k,v in pairs(val) do
--       n = node.new(a_whatsit_node, subtype_special)
--       node.setfield(n, "data", v)
--       head, tail = node.insert_after(head, tail, n)
--    end
--    return head, tail
-- end
 
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

local function addLastLink(parts)
   local tmp = ''
   if parts == false then
      annsubcounter = 0
      anncounter = anncounter + 1
      tmp = 'LinkAnn'.. anncounter
   else
      annsubcounter = annsubcounter + 1
      tmp = 'LinkAnn' .. anncounter .. '_' .. annsubcounter      
   end
   if config.debug then log("addLastLink %s", tmp) end
   tex.sprint(tmp)
   return tmp
end

-- maintained/created by distiller
local function IDTree(stree, head)
   return head
end

-- need to flush for correct Parenttree
local function finalize(head)
   local n = node.new(a_whatsit_node, subtype_special)
   node.setfield(n,"data", "ps::[/StPopAll pdfmark")
   local tail = node.tail(head)
   local head, tail = node.insert_after(head, tail, n)
   return head
end

local writer = {
   init = init,
   addToUnicode = addToUnicode,
   space        = space,
   markLine     = markLine,
   markPara     = markPara,
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
   structStart  = structStart,
   addLastLink  = addLastLink,
   IDTree       = IDTree,
   finalize     = finalize,
   -- savepos      = savepos
}
return writer
