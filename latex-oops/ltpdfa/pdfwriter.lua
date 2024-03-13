--[[
   This is the pdf output driver
--]]
local a_whatsit_node   = node.id("whatsit")
local subtype_pdfliteral = node.subtype("pdf_literal")
local subtype_savepos = node.subtype("save_pos")
local subtype_pdfobj = node.subtype("pdf_obj")
local subtype_latelua = node.subtype("late_lua")
local config = ltpdfa.config
local idarray = {}
local idobjarray = {}
local partreeobj
local idtreeobj
local strkeys = {"neededID", "T", "Lang", "altText", "E", "ActualText"}
local rmstr = ""
-- now create hyphnode
local hyphnode = node.new(a_whatsit_node, subtype_pdfliteral)
hyphnode.mode = 0
hyphnode.data = "q 0 0 1 RG 1.8 w 5 0 m 5 7 l S Q"
-----------------------------------------------------------
local function init()
   log("pdfwriter init")
   -- compression settings has no effect, if objects already written before
   if (config.debug) then
      pdf.setcompresslevel(0)
   end
   -- when not zero no PAC checkmarks but i.O. ???
   -- \pdfvariable objcompresslevel \numexpr 0\relax
   pdf.setobjcompresslevel(0)
   -- \pdfvariable suppressoptionalinfo \numexpr 1 \relax%+2+4+8+16+32+64+128+256+512
   -- suppressoptionalinfo needed once but ...
   -- \pdfvariable omitcidset \numexpr 1 \relax%%% since TL2018, aiming at acrobat preflight
   pdf.setomitcidset(1)
   tex.sprint('\\ifnum\\outputmode=1\\relax\\else\\PackageError{ltpdfa}{No pdf output selected}{You have to use outputmode=1}\\fi')
end

local function addToUnicode(config)
   --     wird ersetzt durch \input glyphtounicode-cmr in der tex datei
end

local function scaleFigure(llx, lly, urx, ury, xscale, yscale, clip, transform_)
   local tx = 0
   local ty = 0
   local x1,y1 = transform_(llx, lly, xscale, 0, 0, yscale, tx, ty)
   local x2,y2 = transform_(urx, ury, xscale, 0, 0, yscale, tx, ty)
   local fbox = {}
   fbox['x1'] = x1
   fbox['x2'] = x2
   fbox['y1'] = y1
   fbox['y2'] = y2
   return fbox
end

local function space(head, lastglyph, spacetemplate, spacekern)
   if (config.debug) then log("\tpdf: space") end
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

local function hyphenation(head, curr)
   if config.debug then log("\tpdf: hyphenation") end
   local n = node.new(a_whatsit_node, subtype_pdfliteral) --- .attr + mode(setorigin,page,direct) + .data fields
   local hyphen = "<00AD>"
   node.setfield(n,"data"," /Span <</ActualText <FEFF00AD> >> BDC ")
   -- TODO
   ----node.attr = curr.attr
   node.insert_before(head, curr, n)
   local m = node.new(a_whatsit_node, subtype_pdfliteral) --- .attr + .data fields
   node.setfield(m,"data"," EMC ")
   if config.debug and config.showspaces and hyphnode then
      node.insert_after(head, curr, m)
      return node.insert_after(head, m, node.copy(hyphnode))
   else
      return node.insert_after(head, curr, m)
   end
end

local function beginMC(head, curr, attrval, mcid, isArtifact, attributes, sparent, at)
   if (config.debug) then log("beginMC") end
   local n = node.new(a_whatsit_node, subtype_pdfliteral)
   node.setfield(n,"attr", curr.attr)
   node.setfield(n,"mode", 1)
   --  bei einem Artifact startet auch eine mcr jedoch hat sie keine MCID, sondern wird lediglich mit /Artifact gekennzeichnet
   if (isArtifact) then
      node.setfield(n,"data", "/Artifact " .. attributes .. " BDC")
   else
      node.setfield(n,"data", "/" .. config.bdcs[attrval] .. " <</MCID " .. mcid .. ">> BDC")
   end
   return node.insert_before(head, curr, n)
end

local function endMC(head, curr, attr, after)
   local n = node.new(a_whatsit_node, subtype_pdfliteral)
   node.setfield(n,"attr", curr.attr)
   node.setfield(n,"data", "EMC \n")
   if (after) then
      return node.insert_after(head, curr, n)
   else
      return node.insert_before(head, curr, n)
   end
end

local function closeElem(selem)
   if (config.debug) then log("pdf: closeElm") end
end

local function createStruct(head, curr, sparent)
   if (config.debug) then log("\tpdf: createStruct") end
end

local function xmpData(filename, head)
   if (config.debug) then log("\tpdf: xmpData") end
   --  die bereits erstellte .xmp Datei wird eingelesen und als immediateobj mit "streamfile" erstellt,
   --  dieses Obj. wird als /Metadata im Catalog referenziert
   local fsize = lfs.attributes(filename, "size")
   local steps = math.ceil(fsize / 4096) + 1
   local xmpobj = pdf.reserveobj()
   if pdf.getcatalog() then
       pdf.setcatalog(pdf.getcatalog() .. " /Metadata " .. xmpobj .. " 0 R ")
   else
       pdf.setcatalog("/Metadata " .. xmpobj .. " 0 R ")
   end
   xmpobj = pdf.obj({type = 'stream', immediate = true, objnum = xmpobj, file = filename, compresslevel = 0, attr = '/Type /Metadata /Subtype /XML'})
   return head
end

local function docInfo(infoarray, head)
   if (config.debug) then log("\tpdf: docInfo") end
   local nstr = ""
   --  das übergebene infoarray wird in einen string konvertiert bei dem die Keys (z.B. Autor, Titel)
   --  mit / und die Werte in () gekennzeichnet werden
   for name, val in pairs(infoarray) do
      nstr = nstr .. " /" .. name .. " (" .. val .. ") "
   end
   pdf.setinfo(nstr)
   return head
end

local function docLang(lang, head)
   --  die übergebene Sprache wird zusammen mit der ViewerPreference in den Catalog getragen
   pdf.setcatalog(pdf.getcatalog().."/Lang("..lang..") /ViewerPreferences<</DisplayDocTitle true>>")
   return head
end

local function addAttribute(selem, attr, str, pdfobj)
   local attrval = selem[attr]
   if (attrval) then
      if (attr == "altText") then attr = "Alt" end
      if (attr == "neededID") then
         attr = "ID"
         table.insert(idarray, selem.ID)
         idobjarray[selem.ID] = pdfobj .. " 0 R "
      end
      return str .. "/" .. attr .. " (" .. attrval .. ") "
   else
      return str
   end
end

-- childs = array of childs, ppdfobj = pdfobj of parent
local function structElems(childs, ppdfobj)
   local cstr = ""
   for k,v in pairs(childs) do
      if (v.idx) then
         local pdfobj = pdf.reserveobj()
         v.pdfobj = pdfobj
         cstr = cstr .. pdfobj .. " 0 R "
         local nstr = "<< /Type /StructElem  /S /" .. v.type .. " /P " .. ppdfobj .. " 0 R  /Pg " .. pdf.pageref(v.startpage) .. " 0 R "
         local kids = structElems(v.childs, pdfobj)
         if (v.relObj) then
            local refobj = ""
            for l,w in pairs(v.relObj) do
               refobj = refobj .. " << /Type /OBJR /Obj " .. w .. " 0 R >>"
            end
            kids = kids .. refobj
         end
         for key,val in pairs(strkeys) do
            nstr = addAttribute(v, val, nstr, pdfobj)
         end
         if (v.attributes) then
            local astr = "/A ["
            for key, value in pairs(v.attributes) do
               local fstr = ""
               for k, val in pairs(value) do
                  fstr = fstr .. val .. " "
               end
               fstr = "<< /O /" .. key .. " " .. fstr .. ">> "
               astr = astr .. fstr
            end
            nstr = nstr .. astr .. "] "
         end
         nstr = nstr .. "/K [".. kids .."] >>"
         pdfobj = pdf.immediateobj(pdfobj, nstr)
      else
         cstr = cstr .. "<</Type /MCR /Pg " .. pdf.pageref(v.startpage) .. " 0 R /MCID " .. v.mcid .. " >> "
      end
   end
   return cstr
end

local function roleMap(stree, head)
   local nstr = ""
   for k,v in pairs(stree.rolemap) do
      log("\t %s => %s",k, v)
      nstr = nstr .. '/' .. k .. ' /' .. v .. '\n'
   end
   return head, nstr
end

local function structTree(stree, head)
   if (config.debug) then log("\tpdf: structTree") end
   local streeobj = pdf.reserveobj()
   partreeobj = pdf.reserveobj()
   idtreeobj = pdf.reserveobj()
   pdf.setcatalog("/MarkInfo <</Marked true>> /StructTreeRoot " .. streeobj .. " 0 R" .. pdf.getcatalog())
   local kids = structElems(stree.root.childs, streeobj)
   head, rmstr = roleMap(stree, head)
   streeobj = pdf.immediateobj(streeobj, "<< /Type /StructTreeRoot ".. " /K [" .. kids .."] /RoleMap <<" .. rmstr .. ">> /ParentTree " .. partreeobj .. " 0 R /IDTree " .. idtreeobj .. " 0 R >>")
   table.sort(idarray)
   return head
end

local function structParent(head, curr, number)
   pdf.setpageattributes(" /Tabs /S /StructParents " .. number)
   return head, curr
end

--- see getStructParent, start with 1
local function parentTree(stree, head)
   local j = 1
   local min
   local max
   if (config.debug) then log("\tpdf: parentTree") end
   local tstr = ""
   local cstr = ""
   local ptree = stree.parenttree
   for key,value in pairs(ptree) do
      if (j == 1) then
         min = key
      end
      local astr = ""
      if (value.discrete) then
         treeval = value.pdfobj
      else
         for k, v in pairs(value) do
            if (not v.pdfobj) then
               dumpArray(v)
               log("parenttree (length=%d) at %d/%d idx=%d has no treeval (pdfobj)",#value, key, k, v.idx)
            end
            astr = astr .. v.pdfobj .. " 0 R "
         end
         mcrarray = pdf.immediateobj("[" .. astr .. "]")
         treeval = mcrarray
      end
      if (not treeval) then
         dumpArray(value)
         log("parenttree (length=%d) at %d has no treeval", #value, key)
         goto continue
      end
      tstr = tstr .. key .. " " .. treeval .. " 0 R "
      max = key 
      if (j == 50) then
         nstr = "<< /Limits [".. min .. " " .. max .."] \n /Nums [" .. tstr .. "] >>"
         intnode = pdf.immediateobj(nstr)
         cstr = cstr .. intnode .. " 0 R "
         j = 1
         tstr = ""
      else
         j = j + 1
      end
      ::continue::
   end
   nstr = "<< /Limits [".. min .. " " .. max .."] \n /Nums [" .. tstr .. "] >>"
   intnode = pdf.immediateobj(nstr)
   cstr = cstr .. intnode .. " 0 R "
   partreeobj = pdf.immediateobj(partreeobj, "<< /Kids [" .. cstr .. "] >>")
   return head
end

local function IDTree(head)
   local min = idarray[1]
   local max = idarray[#idarray]
   local nstr = ""
   if (idarray[#idarray]) then
      for k,v in ipairs(idarray) do
         nstr = nstr .. " (" .. v .. ") " .. idobjarray[v]
      end
      idtreeleaf = pdf.immediateobj("<< /Limits [(".. min .. ") (" .. max .. ")] /Names [" .. nstr .. "] >>")
      idtreeobj = pdf.immediateobj(idtreeobj, "<< /Kids [" .. idtreeleaf .. " 0 R] >>")
   end
   return head
end

local function finalize(head)
   return head
end

local function addLastLink()
   if (config.debug) then log("addLastLink %s", pdf.getlastlink()) end
   return pdf.getlastlink()
end

local function intent(head)
   local profile = config.intent.profile
   local filename = kpse.find_file(profile)
   if filename == nil then
      log("Profile %s could not be found!!!", profile)
      return
   else
      log("Using profile %s", filename)
   end
   local iccstream = pdf.immediateobj("streamfile", filename, "/N " .. config.intent.components)
   local nstr = "<</Type/OutputIntent /RegistryName(http://www.color.org) /S/GTS_PDFA1 /OutputCondition() /OutputConditionIdentifier (" .. config.intent.identifier .. ") /DestOutputProfile " .. iccstream .. " 0 R>>"
   local intentobjnum = pdf.immediateobj(nstr)
   pdf.setcatalog( '/OutputIntents [ ' .. intentobjnum .. ' 0 R ]')
end

local function savepos(head, curr, index, start)
   if (config.debug) then log("\tpdf: savepos") end
   local funcname
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

local writer = {
   init = init,
   addToUnicode   = addToUnicode,
   space          = space,
   hyphenation    = hyphenation,
   beginMC        = beginMC,
   endMC          = endMC,
   --createElem   = pdfcreateelem,
   closeElem      = closeElem,
   createStruct   = createStruct,
   xmpData        = xmpData,
   docInfo        = docInfo,
   docLang        = docLang,
   addAttribute   = addAttribute,
   structElems    = structElems,
   structTree     = structTree,
   structParent   = structParent,
   parentTree     = parentTree,
   IDTree         = IDTree,
   roleMap        = roleMap,
   addLastLink    = addLastLink,
   intent         = intent,
   savepos        = savepos,
   finalize       = finalize,
   scaleFigure    = scaleFigure,
}
return writer
