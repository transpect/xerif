--[[
   contains the tree handling code
   contains node traversing code
   writes BDC, maintain MCID counts etc.
   writing BDC to output with help of writer
--]]

--[[
   The current return value of node.types() is: hlist (0), vlist (1), rule (2), ins (3), mark (4), ad-
   just (5), boundary (6), disc (7), whatsit (8), local_par (9), dir (10), math (11), glue (12), kern
   (13), penalty (14), unset (15), style (16), choice (17), noad (18), radical (19), fraction (20),
   accent (21), fence (22), math_char (23), sub_box (24), sub_mlist (25), math_text_char (26),
   delim (27), margin_kern (28), glyph (29), align_record (30), pseudo_file (31), pseudo_line
   (32), page_insert (33), split_insert (34), expr_stack (35), nested_list (36), span (37),
   attribute (38), glue_spec (39), attribute_list (40), temp (41), align_stack (42), move-
   ment_stack (43), if_stack (44), unhyphenated (45), hyphenated (46), delta (47), passive (48),
   shape (49).
   leaders are glue nodes

   As a page is ready for shipout we:
   - prepare stree.parenttree, mcidcnt, line, lastGlyph
   - we scan for boundaries
   - then insert spaces ??
   - last we insert StructParent
   - autoclose is tricky, because \structopen opens a group, \structclose has corresponding \egroup
   beginEnv/endEnv misses this
   we should not close structs from pageprocessor or alike
   - very last write all needed structures
]]--

-- variables
local a_glyph = node.id("glyph")
local a_disc = node.id("disc")
local a_glue = node.id("glue")
local a_kern = node.id("kern")
local a_penalty = node.id("penalty")
local a_hlist = node.id("hlist")
local a_vlist = node.id("vlist")
local a_whatsit = node.id("whatsit")
local a_local_par = node.id("local_par")
local a_rule = node.id("rule")
local a_mark = node.id("mark")
local a_math = node.id("math")
local a_dir = node.id("dir")
local a_adjust = node.id("adjust")
local subtype_special = 3
local subtype_latelua = 7

local typeattr       = ltpdfa.typeattr
local parentattr     = ltpdfa.parentattr
local spaceattr      = ltpdfa.spaceattr
local writer         = nil
local config         = ltpdfa.config

local mcidcnt
local ptreeentry
local unsetattr = -2147483647 -- constant for unset or beginning of page
local lastattr = unsetattr
local lastnode = nil -- last 'interesting' node with currattr == lastattr
local nextparent = nil -- for extra (nonpage) entries in parenttree
local figures = {}     -- convention always sp
local posfile = tex.jobname .. '.lua' -- posfile in bp
local posoutfile = nil
local positions = {}   -- convention always sp
-- Grouping elements
local grse = {'Document', 'Part', 'Art', 'Sect', 'Div', 'BlockQuote', 'Caption', 'TOC', 'TOCI', 'Index', 'NonStruct', 'Private'}
-- Block-Level-Elements (can be nested, direct child MCID's are treated as ILSE)
local blse = {'P', 'H', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'L', 'Lbl', 'LI', 'LBody', 'Table'}
-- Illustration-Elements and exceptions treated as neither blse nor ilse and ...
local ilse = {'Formula', 'Figure', 'Form', 'TR', 'TH', 'TD', 'THead', 'TBody', 'TFoot'}
local removed = false -- structRemove sets this, ignoreNext too
local inmath = 0
local ignore = false

--[[ this is our main struct
   'root' => contains tree of StructElem objects
   classmap, rolemap
   current is pointer to actual open struct
   parenttree => holds linear array of objects for pages first and then direct pdf objects, starts with 1 (lua arrays!)
   structarray => linear array of StructElem indexed by elem.idx, serves as cache, only used here (this module), indexed by count
   openedarray => structs configured to be autoclosed are pushed here
   count => TODO
--]]
local stree     = { -- structtree object, nothing to do with StructElem!
   root         = {}, -- structelem root of StructElem's
   current      = {}, -- currently open element
   classmap     = {},
   rolemap      = {}, -- pairs of mapping 'Standardtypes' 'our types'
   parenttree   = {}, -- collects entries for /ParentTree pdfobjects
   structarray  = {}, -- number to StructElem mapping (cache)
   openedarray  = {}, -- opened autoclose structs (inputtagger)
   count        = 0,  -- just statistics
}

-- functions
-- debug output
function dumpStructs(T, level)
   local indent = string.rep("  ", level)
   log("%sdump %s",indent, T)
   for k,v in pairs(T) do
      log("%s%s => %s",indent, k, v)
   end
   if (T.attributes) then
      log("%sdumping sattributes", indent)
      dumpArray(T.attributes,1, level)
   end
   if (T.childs) then
      log("%sNumChilds %d", indent, #T.childs)
      for k,v in ipairs(T.childs) do
         log("%sdumping child %s", indent, k)
         dumpStructs(v, level + 1)
      end
   end
end

local function dumpParentTree()
   for k,v in pairs(stree.parenttree) do
      -- v ist StructElem or {}
      if ( v.type ~= nil ) then
         log("  %d => %s / %s", k, v.type, v)
      else
         log("  %d => %s (length %d)", k, v, #v)
      end
   end
end

local function NodeNumber(n)
   return tostring(n):match("<%s+(%d+)%s+>")
end

-- some fixed factors/scales
local bppt_sc = 7227 / 7200          -- bp points to pt(TeX)
local ptbp_sc = 7200 / 7227          -- pt to bp
local bpsp_sc = 7227 / 7200 * 65536  -- bp to sp
local spbp_sc = (7200 / 7227)/65536  -- sp to bp

local function sptobp (arg)
   local num = tonumber(arg)
   return num * spbp_sc
end

local function mmtosp(arg)
   local num = tonumber(arg)
   return num * (7227 / 2540) * 65536
end

local function pttosp(arg)
   local num = tonumber(arg)
   return num * 65536
end

-- local function addPara(bparent, forced)
--    --log("Will add AUTOPARA after %d parent=%s/%d %s isinline=%s", mcidcnt, sparent.type, sparent.idx, lastpara, isinline)
--    --log("\t AUTOPARA after searching BLOCK parent=%s/%d", blockparent.type, blockparent.idx)
--    local idx = bparent:addPara(forced)
--    return idx
-- end

-- search for 'block', 'grouping' etc. parent specified in ltype arg
-- maybe we need list of parent from selem to matched parent
-- returns false or selem
-- local function getParentOfType(selem, ltype)
--    local parent = selem
--    while parent.ltype ~= ltype do
--       if parent.idx == 1 then break end -- document
--       parent = parent.parent
--    end
--    if parent.ltype == ltype then
--       return parent
--    else
--       return false
--    end
-- end
-- sparent = StructElem, currattr = number
-- currattr => no blse or grouping
-- returns a parent to insert (grouping element) or false
-- local function checkAutoPara(sparent, currattr, level)
--    if not config.doparas then return false end
--    if sparent.ltype == -2 then return false end -- artifact
--    -- if not in rolemap possibly standard element
--    local level = level or 0
--    local indent = string.rep("  ", level)
--    local prole = stree.rolemap[sparent.type] or sparent.type
--    local erole = stree.rolemap[config.bdcs[currattr]] or config.bdcs[currattr]
--    local needspara = (sparent.ltype > 0)
--    -- search for 'block' parent
--    local tparent = getParentOfType(sparent, 0)
--    if config.debug then
--       local s = "No"
--       if tparent then s = tparent.type end
--       log("%scheckAutoPara enter for sparent=%s(%s)/%s tparent=%s(%s)", indent, sparent.type, sparent.ltype, #sparent.childs, tparent, s)
--    end
--    --[[
--       we come from pagecontent
--       if this is block but has inline parent(s) without direct content we miss checking those
--       and do not create autopara for it 
--       - e.g. footnotemark => <Reference><Lbl>val</Lbl></Reference>
--       simple algo starts at Lbl which is block and stops
--       TODO check that parent has childs with mcid, these had triggered autoparacheck before
--       -> need to check for childs that are mcid
--       if we recurse we must move
--    --]]
--    if (tparent == sparent and sparent.parent.ltype == 2 and (not sparent.parent:hasContentChilds())) then
--       if config.debug then log("%scheckAutoPara recursion for parent=%s(%s/%s)", indent, sparent.parent.type, sparent.parent.ltype, sparent.type) end
--       -- recursion
--       local ttparent = checkAutoPara(sparent.parent, config.bdcs[sparent.parent.type], level + 1)
--       if (ttparent and ttparent.ltype == 1) then
--          --create para here sparent.parent has to become child of para
--          -- TODO what if sparent.parent is not direct child of ttparent
--          local idx = ttparent:removeChild(sparent.parent)
--          --if config.debug then log("%scheckAutoPara removing %s from %s idx=%s lastUsed=%s", indent, sparent.parent.type, ttparent.type, idx, ttparent.lastUsed) end
--          idx = ttparent:addPara(sparent.parent.forced)
--          if config.debug then
--             log("%sadded AP %s with %s into %s idx=%s", indent, ttparent.actpara, sparent.parent.type, ttparent.type, idx)
--          end
--          sparent.parent.parent = ttparent.actpara
--          table.insert(ttparent.actpara.childs, sparent.parent)
--          sparent.parent:adjustInsert()
--       end
--    end
--    -- return if sparent or some parent of it is block
--    if tparent and tparent.ltype == 0 then
--       if config.debug then log("%scheckAutoPara NOPARA for PARENTROLE=%s(%s) ELEMENTROLE=%s(%s)", indent, prole, sparent.type, erole, config.bdcs[currattr]) end
--       return false
--    end
--    -- no block parent, try next grouping
--    tparent = getParentOfType(sparent, 1)
--    if config.debug then
--       local setype = "UNKNOWN"
--       if sparent.ltype == 1 then
--          setype = "Grouping"
--       elseif sparent.ltype == 0 then
--          setype = "Block"
--       elseif sparent.ltype == 2 then
--          setype = "Inline"
--       elseif sparent.ltype == -1 then
--          setype = "Illustration"
--       elseif sparent.ltype == -2 then
--          setype = "Artifact"
--       end
--       log("%scheckAutoPara for %s(%s) PARENT=%s(%s) ELEMEN=%s(%s)", indent, setype, needspara, prole, sparent.type, erole, config.bdcs[currattr])
--       log("%sAUTOPARA in %s type=%s", indent, tparent.type, tparent.ltype)
--    end
--    return tparent
-- end
--[[
   - start marking the following content at page
   - writer creates pdfobject for struct if not already done
   - writer put marks into the content stream
   - for artifacts just put the marks
   - maintain parent relation
   - check for blse - insert autoparas
--]]
local function markElement(head,curr,sparent,currattr)
   if (sparent.created == false) then
      if config.debug then log("writer create StructElem %s %s",sparent.type, head) end
      writer.createStruct(head, curr, sparent)
      sparent.created = true
   end
   local directattr = nil
   local idx
   if (sparent.isArtifact and config.artifact[sparent.type]) then
      directattr = "<</Type/" .. config.artifact[sparent.type].Type 
      if config.artifact[sparent.type].Subtype then
         directattr = directattr .. "/Subtype/" .. config.artifact[sparent.type].Subtype
      end
      directattr = directattr .. ">>"
      head = writer.beginMC(head, curr, math.abs(currattr), mcidcnt, sparent.isArtifact, directattr, sparent, idx)
      return head
   end
   --local blockparent = checkAutoPara(sparent,currattr)
   -- if blockparent and config.doparas then
   --    idx = addPara(blockparent, sparent.forced)
   --    if config.debug then log("markElement addPara %s %s", blockparent.type, idx) end
   --    head = writer.beginMC(head, curr, config.bdcs['autopara'], mcidcnt, sparent.isArtifact, directattr, sparent, idx)
   --    sparent:addMCID(mcidcnt)
   -- else
   idx = sparent:addMCID(mcidcnt)
   head = writer.beginMC(head, curr, math.abs(currattr), mcidcnt, sparent.isArtifact, directattr, sparent, idx)
   -- end
   -- if (sparent.actpara) then
   -- table.insert(ptreeentry, sparent.actpara)
   -- else
   table.insert(ptreeentry, sparent) -- mcidcnt should correspond to tableindex use ptreeentry[mcidcnt] ???
   -- end
   mcidcnt = mcidcnt + 1
   return head
end

-- node processing functions, possibly setting new head
-- enclosing boxes have attribute from page break ;-(
local function noop(parentbox, curr, level) -- do nothing
end
-- TODO check list for "no content"
-- a) immediately close if currattr != lastattr but do not reopen
-- b) immediately open if lastattr == unsetattr (unset)
-- c) just open/reopen at
-- must also check for current == last but other parent!!!
local function process_node(parentbox, curr, level) -- standard processing, maybe only for 'marking' nodes ???
   if (curr.attr == nil) then return end    -- some nodes do not have attrlist
   local head = parentbox.head
   local indent = string.rep(" ", level + 1)
   local currattr = node.get_attribute(curr, typeattr) -- could be nil despite curr.attr is not
   local pattr = node.get_attribute(curr, parentattr)
   local sparent = stree.structarray[pattr]
   if (ltpdfa.config.nodetree == true) then
      log("%s node for %s %s/%s/%s pbox=%d stype=%s", indent, (node.types())[curr.id], lastattr, currattr, pattr, NodeNumber(parentbox), curr.subtype)
   end
   if (currattr ~= lastattr) then
      if (lastattr == unsetattr) then
         -- open env at beginning of page
         head = markElement(head,curr,sparent,currattr)
      elseif (lastattr > 0) then
         writer.endMC(lastnode[1], lastnode[2], lastattr, true) -- head, node, typeattr, after
         head = markElement(head,curr,sparent,currattr)
      end
      lastnode = {head, curr, pattr}
      lastattr = currattr
      parentbox.head = head
   else
      -- check if parent changed and open new element of same type!!!
      if (pattr ~= lastnode[3]) then
         log("Split env due to new Parent! %s %s", pattr, lastnode[3])
         head = writer.endMC(head, curr, node.get_attribute(lastnode[2], typeattr), false) -- head, node, typeattr, after
         head = markElement(head,curr,sparent,currattr)
         parentbox.head = head
      end
      lastnode = {head, curr, pattr} -- remember last 'interesting' node where lastattr == currattr
   end
end
-- arrray with node processing functions
local processNode = {}
for i = 0, 49 do
   processNode[i] = process_node
end
processNode[a_penalty] = noop
processNode[a_kern] = noop
processNode[a_mark] = noop
processNode[a_dir] = noop
processNode[a_adjust] = noop -- ignore vadjust nodes

local function processBox( parentbox, level )
   local indent = string.rep(" ", level)
   local head = parentbox.list
   if config.debug then
      log("%s** prBox parent=%s(%s) (l=%d) (%s) lastattr=%d", indent, (node.types())[parentbox.id], NodeNumber(parentbox), level, head, lastattr)
   end
   for curr in node.traverse(head) do
      local pattr = node.get_attribute(curr, parentattr)
      local currattr = node.get_attribute(curr, typeattr)
      if (debug) then
         --log("%s => %s %s => %s/%s/%s (l=%d) (%s)", indent, curr.id, (node.types())[curr.id], lastattr, currattr, pattr, level, NodeNumber(curr))
      end
      processNode[curr.id](parentbox, curr, level)
   end
   if config.debug then log("%s## prBoxEnd parent=%s (l=%d) %s(%s/%s)", indent, (node.types())[parentbox.id], level, NodeNumber(parentbox), NodeNumber(head), NodeNumber(parentbox.head)) end
end

local function process_vlist(parentbox, curr, level)
   --and ‘subtype’ only has the values 0 = unknown, 4 = alignment, and 5= cell.
   local indent = string.rep(" ", level + 1)
   local head = parentbox.head
   processBox( curr, level + 1 ) -- recurse
end
processNode[a_vlist] = process_vlist
local function process_hlist(parentbox, curr, level)
   -- field
   -- subtype
   -- type
   -- number
   -- explanation
   -- 0 = unknown, 1 = line, 2 = box, 3 = indent, 4 = alignment, 5 = cell,
   -- 6 = equation, 7 = equationnumber
   local head = parentbox.head
   local indent = string.rep(" ", level + 1)
   processBox( curr, level + 1 ) -- recurse
end
processNode[a_hlist] = process_hlist

local function process_localpar(parentbox, curr, level)
   --   lastpara = curr
   -- TODO
   --   lastpara = 0
end
processNode[a_local_par] = process_localpar

-- handle leaders here 100 leaders, 101 cleaders, 102 xleaders, 103 gleaders
local function process_glue(parentbox, curr, level)
   local currattr = node.get_attribute(curr, typeattr)
   local pattr = node.get_attribute(curr, parentattr)
   if (curr.subtype == 100 or curr.subtype == 101) then
      --log("GLUE node for %s %d/%d/%s pbox=%d", (node.types())[curr.id], lastattr, currattr, pattr, NodeNumber(parentbox))
      process_node(parentbox, curr, level)
   end
end
processNode[a_glue] = process_glue -- TODO check, want to only handle leaders

-- deprecate ??, internal use, TODO
local function addFigure_(width, height, depth, parent)
   table.insert(figures, { parent = parent, fbox = {}, ppos = {}} )
   local fig = figures[#figures]['fbox']
   if positions ~= nil and positions[#figures] then
      local pos = positions[#figures]
      local fig = figures[#figures]
      fig['x1'] = pos['x1']
      fig['x2'] = pos['x2']
      fig['y1'] = pos['y1']
      fig['y2'] = pos['y2']
   end
end

local function transform_(x,y,a,b,c,d,tx,ty)
   local xn = a*x + c*y + tx
   local yn = b*x + d*y + ty
   return xn,yn
end

-- TODO maybe delegate to engine specific module!!!
-- \addFigure{\Gin@llx}{\Gin@lly}{\Gin@urx}{\Gin@ury}, in bp
-- to inject from TeX (graphics), args is bounding box, not BBox :-(
-- let readPosStart and readPosEnd save their values in subkey 'ppos'
-- mimic pscode from special.lpro, origin of painting is 0,0
--
-- luatex
-- - llx, lly, urx, ury are native size of figure
-- - rwi, rhi are caluculated scales
-- - clip obvious
local function addFigure(llx, lly, urx, ury, xscale, yscale, clip)
   log("addFigure llx=%s, lly=%s, urx=%s, ury=%s xscale=%s yscale=%s clip=%s", llx, lly, urx, ury, xscale, yscale, clip)
   local parent = stree.current.idx
   local xscale = tonumber(xscale)
   local yscale = tonumber(yscale)
   local fbox = writer.scaleFigure(llx, lly, urx, ury, xscale, yscale, clip, transform_) -- driver dependent scale to embedsize
   dumpArray(fbox)
   -- TODO implement this in dvi/distwriter
   -- rwi etc. handling is from special.pro => not for other drivers
   -- if (rwi) then
   --    local xscale = (rwi/10)/(urx - llx)
   --    if (rhi) then
   --       yscale = (rhi/10)/(ury - lly)
   --    else
   --       yscale = xscale
   --    end
   --    tx = -llx
   --    ty = -lly
   -- else
   --    if (rhi) then
   --       yscale = (rhi/10)/(ury - lly); xscale = yscale
   --       tx = -llx
   --       ty = -lly
   --    end
   -- end
   -- now we have real size after scaling
   fbox['x2'] = (fbox['x2']-fbox['x1']) * bpsp_sc
   fbox['x1'] = 0.0
   fbox['y2'] = (fbox['y2']-fbox['y1']) * bpsp_sc
   fbox['y1'] = 0.0
   table.insert(figures, { parent = parent, fbox = fbox, ppos = {}} )
   if config.debug then
      log("addCFigure %s idx=%d", parent, #figures)
      log("\t%s idx=%d scale:%.2f/%.2f urx=%s / ury=%s ", parent, #figures, xscale, yscale, urx, ury)
      log("\ttransformed %.2f,%.2f/%.2f,%.2f", fbox['x1'], fbox['y1'], fbox['x2'], fbox['y2'])
      dumpArray(fbox)
   end
end

-- try to ignore empty rules
-- catch images, we need BBOX for them
-- set parent into list of images
local function process_rule(parentbox, curr, level)
   -- -1073741824 used for widht if 'running' glue, but need this for \hrule
   local currattr = node.get_attribute(curr, typeattr)
   local pattr = node.get_attribute(curr, parentattr)
   -- why did I added 'running' check if (curr.width == 0 or curr.width == -1073741824) then return end
   -- answer too many \hrules in \vspace etc.
   if (curr.subtype == 0) then
      if (curr.width == 0) then return end
      if (curr.height == 0 and curr.depth == 0) then return end
   elseif (curr.subtype == 2) then    --subtype 2 are images ONLY FOR PDFOUTPUT
      -- could be artifact
      log("Figure (rule): page %d at %d index=%d\n\t %d %d %d", status.total_pages + 1, tex.inputlineno, curr.index, curr.width, curr.height, curr.depth)
      log("Figure (rule): width=%f height=%f depth=%s matrix=%s", curr.width/65536.0, curr.height/65536.0, curr.depth/65536.0, pdf.hasmatrix())
      -- DEPRECATE addFigure_(curr.width, curr.height, curr.depth, pattr)
      --insert a savepos before and after and read values back => latelua
      -- local head, new = writer.savepos(parentbox.list, curr, #figures, true) -- true means start
      -- head, new = writer.savepos(head, curr, #figures, false) -- false means end
      -- parentbox.head = head
   end
   process_node(parentbox, curr, level)
end
processNode[a_rule] = process_rule

-- dvi output includes graphics by special PSfile=... sigh
-- WHATSIT subtype: special; data: PSfile="suppl/TeXlogo.eps" llx=0 lly=-1 urx=813 ury=436 rwi=1031 ;
-- savepos here return same x,y-vals as 3 contigous whatsit does not change postion :-(
-- so essentially this func does only enable markelem for figures
local function process_whatsit(parentbox, curr, level)
   if curr.subtype == subtype_special then
      local currattr = node.get_attribute(curr, typeattr)
      local pattr = node.get_attribute(curr, parentattr)
      if config.debug then log("WHATSIT: page %d at %d data=%s currattr=%s", status.total_pages + 1, tex.inputlineno, curr.data, currattr) end
      local str = curr.data:match('^PSfile=".+%.[eE][pP][sS]"')
      if str ~= nil then
         local tail = node.tail(parentbox.list)
         if config.debug then log("Figure: page %d at %d data=%s match=%s", status.total_pages + 1, tex.inputlineno, curr.data, str) end
         -- must have been called before !!! addFigure_(0, 0, 0, pattr)
         -- local head, new = writer.savepos(parentbox.list, curr, #figures, true) -- true means start
         -- head, new = writer.savepos(parentbox.list, curr, #figures, false) -- false means end
         -- parentbox.head = head
         process_node(parentbox, curr, level)
      end
   end
end
processNode[a_whatsit] = process_whatsit

local function process_math(parentbox, curr, level)
   local currattr = node.get_attribute(curr, typeattr) -- could be nil despite curr.attr is not
   if (ltpdfa.config.nodetree == true) then
      local pattr = node.get_attribute(curr, parentattr)
      log("%s node for %s %s/%s/%s pbox=%d stype=%s", string.rep(" ", level + 1), (node.types())[curr.id], lastattr, currattr, pattr, NodeNumber(parentbox), curr.subtype)
   end
   if curr.subtype == 0 then
      inmath = inmath + 1
      -- local currattr = node.get_attribute(curr, typeattr)
      -- local pattr = node.get_attribute(curr, parentattr)
   elseif curr.subtype == 1 then
      inmath = inmath - 1
   end
   if config.debug then log("MATH: page %d at %d currattr=%s inmath=%d", status.total_pages + 1, tex.inputlineno, currattr, inmath) end
end
processNode[a_math] = process_math

-- give figures their BBox
-- TODO check!!! width and height are from addFigure_ or addFigure, x,y from readPos
-- coordinate from savepos have origin at lower left and y increases to top 
local function postProcessFigs()
   for k,v in pairs(figures) do
      local fbox = v.fbox; local ppos = v.ppos
      -- fbox checks
      if (fbox.x1 == nil or fbox.x2 == nil or fbox.y1 == nil or fbox.y2 == nil) then
         tex.error("Error: incomplete figure (fbox)" .. k .. " " .. v.parent)
         return false
      end
      if (ppos.x1 == nil or ppos.x2 == nil or ppos.y1 == nil or ppos.y2 == nil) then
         tex.error("Error: incomplete figure (ppos)" .. k .. " " .. v.parent)
         return false
      end

      -- normalize
      local tmp;
      if fbox.x1 > fbox.x2 then
         tmp = fbox.x1; fbox.x1 = fbox.x2; fbox.x2 = tmp;
      end
      if fbox.y1 > fbox.y2 then
         tmp = fbox.y1; fbox.y1 = fbox.y2; fbox.y2 = tmp;
      end
      if ppos.x1 > ppos.x2 then
         tmp = ppos.x1; ppos.x1 = ppos.x2; ppos.x2 = tmp;
      end
      if ppos.y1 > ppos.y2 then
         tmp = ppos.y1; ppos.y1 = ppos.y2; ppos.y2 = tmp;
      end
      
      -- small figures
      if ( ((fbox.x2 - fbox.x1) < 100) or ((fbox.y2 - fbox.y1) < 100)) then
         log("Warning: very small figure %d", v.parent)
      end
      -- ppos checks
      if ( (ppos.x2 - ppos.x1) < 100) then
         log("Warning: very small x-ppos %d", v.parent)
      end
      if ( (ppos.y2 - ppos.y1) < 100) then
         log("Warning: very small y-ppos %d (%d/%d)(%.2f/%.2f)\n => %.2f", v.parent, ppos.y1, ppos.y2, fbox.y1, fbox.y2, (fbox.y2 - fbox.y1))
         dumpArray(v,true)
         -- set y2 from fpos
         ppos.y2 = ppos.y1 + (fbox.y2 - fbox.y1) 
      end

      if v.parent then
         local s = stree.structarray[v.parent]
         local bboxA = string.format("/BBox [%.2f %.2f %.2f %.2f]", sptobp(ppos.x1), sptobp(ppos.y1), sptobp(ppos.x2), sptobp(ppos.y2))
         local bbox = string.format("/BBox [%.2f %.2f %.2f %.2f]", sptobp(fbox.x1), sptobp(fbox.y1), sptobp(fbox.x2), sptobp(fbox.y2))
         s:addToAttributes('Layout', bboxA)
      end
   end
end

-- manually add figure TODO move down, do we need \savepos
local function savePosStart(create)
   if create then
      addFigure_(0, 0, 0, stree.current.idx)
      tex.sprint(config.ltpdfCatcode, '\\latelua{ltpdfa.structtree.readPosStart(' .. #figures .. ')}')
   else
      tex.sprint(config.ltpdfCatcode, '\\latelua{ltpdfa.structtree.readPosStart(' .. #figures + 1 .. ')}')
   end
end

local function savePosEnd()
   tex.sprint(config.ltpdfCatcode, '\\latelua{ltpdfa.structtree.readPosEnd(' .. #figures .. ')}')
end

local function figureSet(key, value, unit)
   local keyset = "width height depth"
   log("SETFIGURE %s %s %s", key, value, unit)
   -- TODO for width, height, depth dropped them use x1 etc.
   if (string.find(keyset, key)) then
      if (unit == 'mm') then
         value = mmtosp(value)
      elseif (unit == 'bp') then
         value = bptosp(value)
      elseif (unit == 'pt') then
         value = pttosp(value)
      else
         log("Error: Unknown unit %s in setFigure!", unit)
      end
      local fig = figures[#figures]
      fig[key] = value
   else
      log("Error: SETFIGURE key %s not known!", key)
   end
end

local function removeArtifacts_(parent)
   if (parent.childs) then
      local i=1
      while i <= #parent.childs do
         if (parent.childs[i].isArtifact) then
            if config.debug then log("Removing artifact %s %s", parent.type, parent.childs[i].ID) end
            table.remove(parent.childs, i)
         else
            i = i + 1
         end
      end
      -- child artifacts removed, traverse tree
      for k,v in pairs(parent.childs) do
         removeArtifacts_(v)
      end
   end
end

local function removeArtifacts()
   removeArtifacts_(stree.root)
end

-- TODO call parent again - maybe became empty
local function removeEmptyStructs_(parent)
   if (parent.childs) then
      local i=1
      while i <= #parent.childs do
         local child = parent.childs[i]
         -- 1. for empty TD/TH needed (e.g. in THead) due to 'regularity in tables'
         -- 2. must generally have to be removed for rowspan ;-(
         if (child.idx and #child.childs == 0) then
            if (child.keep) then -- let empty tablecells persist or make artifact
               if config.debug then log("Removing empty Struct let TD in place %s(%d) from parent %s(%d)", child.type, child.idx, parent.type, parent.idx) end
               i = i + 1
            else
               if config.debug then log("Removing empty Struct %s(%d) from parent %s(%d)", child.type, child.idx, parent.type, parent.idx) end
               table.remove(parent.childs, i)
            end
         else
            i = i + 1
         end
      end
      -- empty childs removed, traverse tree
      for k,v in pairs(parent.childs) do
         if (v.idx) then removeEmptyStructs_(v) end
      end
   end
end

local function removeEmptyStructs()
   removeEmptyStructs_(stree.root)
end

local function splitPath(nstr, delimiter)
   local result = {}
   local from = 1
   local delim_from, delim_to = nstr:find(delimiter, from)
   while delim_from do
      table.insert(result, string.sub(nstr, from , delim_from-1))
      from  = delim_to + 1
      delim_from, delim_to = string.find(nstr, delimiter, from)
   end
   table.insert(result, string.sub(nstr, from))
   return result
end

-- step forward/backward in childs of context node to find elnum-th occurrence of ctype
local function findChild(ctype, elnum, context)
   local inc = 1
   local start = 1
   local stop  = #context.cnode.childs
   local num = elnum
   if (num < 0) then
      inc = -1
      start = stop
      stop = 1
      num = -num
   end
   for i = start, stop, inc do
      local val = context.cnode.childs[i]
      if (val.type == ctype) then
         num = num - 1
      end
      if (num == 0) then
         context.cnode = val
         context.match = val
         if config.debug then log("findChild: setting %s %s %s/%s (%s)", ctype, val.type, i, elnum, context.cnode.ID) end
         break
      end
   end
end

-- processes path and split into single steps + cpos
local function buildSteps(context)
   -- first '/' already removed
   -- is valid?? no '/'
   if (context.path:find('/') == 1) then
      log("setNewParent cannot work with path %s\n", context.path)
      tex.error("setNewParent cannot work with path " .. context.path .."!\n")
   end
   local steps = splitPath(context.path, "/")
   -- target position at end /[NUM]
   context.cpos = steps[#steps]
   context.cpos = tonumber(context.cpos:sub(2,-2))
   steps[#steps] = nil --remove childpos (last component) 
   context.steps = {} -- pairs of {type, pos}
   for k,v in pairs(steps) do
      local nstr = v:sub(1,-2) -- remove trailing ']'
      local s = splitPath(nstr, "%[")
      -- axis
      local num= s[2]:match("([^,]+),?([^,]?)") -- local num, axis = s[2]:match("([^,]+),?([^,]+)?")
      table.insert(context.steps, {s[1], num, axis})
   end
end

local function findElem(context)
   buildSteps(context)
   dumpArray(context.steps,1)
   for k,v in pairs(context.steps) do
      -- one step - starts with context.cnode
      context.match = nil
      local ctype = v[1]
      local elnum = tonumber(v[2])
      local axis = v[3]
      if elnum == 0 then tex.error("Invalid step in %s!\n", context.path) end
      if config.debug then log("Search for %s starting at %s", ctype, (context.cnode.ID and context.cnode.ID or context.cnode.type)) end
      -- rel. up
      if (ctype == '..') then
         for x = 1, elnum do
            if config.debug then log("  Searching switch from %s to %s\n", context.cnode.ID, context.cnode.parent.ID) end
            context.cnode = context.cnode.parent
         end
         context.match = context.cnode
      elseif (ctype == '.') then -- keep current does this make sense??? Maybe one up and then only start at current ???
         if config.debug then log("  Searching keep current %s\n", curr.ID) end
         context.match = context.cnode
      else
         -- axis ancestor(A), child(C), following-sibling(S), preceding-sibling(P)
         if (axis and axis == 'A') then
            findAncestor(ctype, elnum, context)
         elseif (axis and axis == 'S') then
            findFollowingS(ctype, elnum, context)
         elseif (axis and axis == 'P') then
            findPrecedingS(ctype, elnum, context)
         elseif (axis and axis == 'C') then
            findChild(ctype, elnum, context)
         else
            -- take as childaxis
            findChild(ctype, elnum, context)
         end
      end
   end
end

-- must remove first, otherwise if insertion and deletion struct are the same, we delete wrong child
local function moveElem(context)
   local oldP = context.selem.parent
   local idx = -1
   for id, val in pairs(oldP.childs) do
      if (val == context.selem) then
         idx = id
         break
      end
   end
   context.selem.parent = context.match
   table.remove(oldP.childs, idx)
   table.insert(context.match.childs, context.cpos, context.selem)
   context.selem.newParent = nil -- just move once
   return idx
end

--[[
   Steps:
   '/' separates steps, '/' at begin starts at root element, no '/' at current node
   - .. one level up
   - . do we need this ???
   - * each child (not allowed at begin of path) TODO NOT IMPLEMENTED YET
   - TYPE[x] x-th child node of type TYPE of current node, negative value from end of childs
   - single [x] at end x is insert position
   so:
   .. | . | * | TYPENAME[NUMBER,AXIS]
   [NUMBER] positiv or negativ
   [AXIS] ancestor(A), child(C), following-sibling(S), preceding-sibling(P)
   [NUMBER] at end/last specifies child pos in found parent (negative from back)

   TODO at the moment we only relized search in child axis
   can we search in parent relative to previous context (from there ???)
   struct context:
     .rel relativ or absolut
     .cnode context node search is operating from
     .cpos = position for move
     .path = full string
     .selem = structure element to move
     .steps = resulting steps

because table.remove moves next elements up on deletion, 
we would miss the following one in pairs(childsarray)
=> so use while i <= #parent.childs do
]]--
local function setNewParent(childsarray)
   local k = 1
   while k <= #childsarray do
      local v = childsarray[k]
      if (v.idx) then
         if (v.newParent) then
            -- rel. or absolut '/', '..', '.' and none of them
            local context = {rel = false, cnode = nil, path = nil, selem = v, steps = nil, cpos = nil}
            if config.debug then log("setNewParent of %s to %s\n", v.ID, v.newParent) end
            if (v.newParent:find('/') == 1) then
               -- remove '/' at start
               v.newParent = v.newParent:sub(2)
               context.rel = false
               context.cnode = ltpdfa.structtree.stree.root
            else
               context.rel = true
               context.cnode = v
            end
            context.path = v.newParent
            findElem(context)
            if (context.match == nil) then
               log("Target of move operation not found!\n")
               tex.error("Target of move operation not found " .. v.newParent .. "!\n")
               break
            else
               if config.debug then
                  log("Moving " .. v.ID .. " from " .. v.parent.ID .." to " .. context.match.ID .. " (" .. v.newParent .. ")" .. " at " .. context.cpos .. ". position")
               end
               local idx = moveElem(context) -- this eventually removes newParent
               k = k - 1
            end
         end
         -- possible we later iterate over moved element again!!!
         setNewParent(v.childs)
      end
      k = k + 1
   end
end

local function finalizeDoc(head)
   -- if config.doparas then
   --    processParas()
   -- end
   if config.dospaces then
      ltpdfa.spaceprocessor.cleanUp()      
   end
   -- postProcessFigs() -- Fig BBoxes
   log("List of environments:")
   dumpArray(config.bdcs)
   if config.debug then
      log("ParentTree:")
      dumpParentTree()
      log("StructTree:")
      dumpStructs(stree.root, 0)
      log("Figures:")
      for k,v in pairs(figures) do
         log("%s => ",k); dumpArray(v, true)
         -- sometimes nil values at first run
         if (v['x1'] ~= nil and v['y1'] ~= nil and v['x2'] ~= nil and v['y2'] ~= nil) then
            -- log("BBOX => %.2f %.2f %.2f %.2f", v['x1'], v['y1'], v['x2'], v['y2'])
            log("BBOX => %.2f %.2f %.2f %.2f", sptobp(v['x1']), sptobp(v['y1']), sptobp(v['x2']), sptobp(v['y2']))
         end
      end
      log("FigPositions:")
      dumpArray(positions, true)
      log("Metadatda:")
      dumpArray(config.metadata, true)
   end
   removeArtifacts()
   removeEmptyStructs()
   log("==== finalizeDoc: at line %d of %s", tex.inputlineno, tex.jobname)
   head = writer.finalize(head)
   if (config.intent ~= nil) then
      writer.intent(head)
   end
   head = writer.docInfo(ltpdfa.metadata.getDocInfo(), head)
   local xmpfile = nil
   if (config.metadata.xmpfile and config.metadata.xmpfile ~= "") then
      local f=io.open(config.metadata.xmpfile,"r")
      if f~=nil then
         io.close(f)
      else
         tex.error("Error: " .. config.metadata.xmpfile .. " could not be found!")
      end
      xmpfile = ltpdfa.metadata.xmphandler.fromFile(config.metadata.xmpfile)
   else
      xmpfile = ltpdfa.metadata.xmphandler.fromInfo()
   end

   head = writer.xmpData(xmpfile, head)
   -- adjust Parents according to newParent
   setNewParent(ltpdfa.structtree.stree.root.childs)
   head = writer.structTree(ltpdfa.structtree.stree, head)
   head = writer.parentTree(ltpdfa.structtree.stree, head)
   head = writer.roleMap(ltpdfa.structtree.stree, head)
   head = writer.IDTree(ltpdfa.structtree.stree, head)
   head = writer.docLang(ltpdfa.config.lang, head)
   log("dump of opened")
   dumpArray(ltpdfa.structtree.stree.openedarray)
end
--[[
   public/exported part
]]--

-- remember stree current at begin of shipout (read inputfile so far)
local currtexstruct = nil
local function buildpage( pagebox )
   if (nextparent == nil) then nextparent = ltpdfa.lastpage end
   currtexstruct = stree.current
   log("**** shipout: page=%d at %d lastattr=%d input selem=%s/%d", status.total_pages + 1, tex.inputlineno, lastattr, currtexstruct.type, currtexstruct.idx)
   mcidcnt = 0
   lastattr = unsetattr -- unset or beginning of page
   stree.parenttree[status.total_pages + 1] = {}
   ptreeentry = stree.parenttree[status.total_pages + 1]
   lastnode = pagebox.list
   processBox(pagebox, 1)
   lastGlyph = {cumulated = 0}
   -- attention inserts different attr-values than surrounding nodes - call after processBox
   if config.dospaces then
      ltpdfa.spaceprocessor.processpage(pagebox)
   end
   local head = pagebox.list
   local tail = node.tail(head)
   -- completely empty page left lastattr == unsetattr
   if (lastattr ~= unsetattr) then
      head, tail = writer.endMC(head, tail, lastattr, true)--node.tail(pagebox.list)
   end
   -- inserts /StructParents to page, see getStructParent, start with 1
   head, tail = writer.structParent(head, tail, status.total_pages + 1)
   if (ltpdfa.config.nodetree == true) then
      nodetree.analyze(pagebox)
   end
   -- reset open struct to view of input
   stree.current = currtexstruct
   log("==== end shipout: at line %d opened=%d pg=%d(%d) current=%s/%d", tex.inputlineno, lastattr, status.total_pages + 1, ltpdfa.lastpage, stree.current.type, stree.current.idx)
   -- ltpdfa.finishOutput depends on ltpdfa.lastpage, this ist not especially robust
   -- maybe we need to remember head, tail in odriver
   -- last page is not shipped out yet
   -- latelua with ReadPos etc. are executed later :-(
   if (ltpdfa.lastpage == (status.total_pages + 1)) then
      ltpdfa.structtree.finalizeDoc(head)
      tail = node.tail(head)
   end
   ltpdfa.lastShippedOut = status.total_pages + 1
end

local function endDocument()
   --    log("List of environments:")
   --    dumpArray(config.bdcs)
   --    log("StructTree:")
   --    dumpStructs(stree.root, 0)
   --    tail = node.tail(head,tail)
end

-- resolved type block=0, grouping=1, inline=2, illustration=-1, artifact=-2???
local function setType(selem)
   selem.isArtifact = false
   if (config.artifact and config.artifact[selem.type]) then
      selem.isArtifact = true
      selem.ltype = -2
      return
   end
   selem.ltype = 2
   local role = stree.rolemap[selem.type] or selem.type
   for k,v in pairs(grse) do
      if (v == role) then
         selem.ltype = 1
         return
      end
   end
   for k,v in pairs(blse) do
      if (v == role) then
         selem.ltype = 0
         return
      end
   end
   for k,v in pairs(ilse) do
      if (v == role) then
         selem.ltype = -1
         return
      end
   end
end

local structelem = require('structelem')
-- setup
structelem.stree = stree
stree.count = 0
stree.root = StructElem:new("StructRoot")
stree.current = stree.root
stree.structarray[0] = stree.root

--[[
   creating new StructElems and build tree from tex-document
   creates StructElem, sets to child of parent
   only maintains structure! no MC
   sets parentattr => MC to Struct mapping
--]]
local function structStart(type, structnum, optparent, doattr) -- structnum unused!!!
   stree.count = stree.count + 1
   if ignore and ignore == type then
      ignore = false
      removed = StructElem:new(type)
      if config.debug then log("Ignoring start of %s", type) end
      return
   end
   local x = StructElem:new(type)
   x.ID = type .. x.idx -- default ID => "TYPENAME+IDX"
   x.parent = stree.current
   setType(x)
   if (optparent) then
      if (x:forceParent(optparent)) then
         -- x.parent changed
         x.restoreParent = stree.current
         if config.debug then log("ZZZ FORCEDPARENT for idx=%d %s => %s == %s(idx=%d)", x.idx, type, optparent, x.parent.type, x.parent.idx) end
      end
   end
   table.insert(x.parent.childs, x)
   x.startpage = status.total_pages + 1
   stree.current = x
   stree.structarray[x.idx] = x
   if doattr then
      tex.setattribute(ltpdfa.parentattr, stree.current.idx) -- let content (BDC) know its parent
   end
end
--[[
   closes StructElem
   nothing for 'onlymc'
--]]
local function structEnd(type)
   local x = stree.current
   if removed and type == removed.type then
      log("Ignoring following %s once because removed/ignored before!", removed.type)
      removed = false
      ignore = false
      return
   end
   if (x.idx == 1) then
      -- never close idx=1
      log("Keeping idx=1 open (%s)", x.type)
      return
   end
   x.endpage = status.total_pages + 1
   currtype = x.type
   if config.debug then log("structtree.structEnd closing!!! arg=%s current has=%s)", type, currtype) end
   if (currtype ~= type) then
      log("WARN: closing wrong type!!! (%s/%s) newcurrent=%s(%s) line %d", currtype, type, x.parent, x.parent.type, tex.inputlineno)
      dumpArray(x)
   end
   writer.closeElem(x)
   if (x.restoreParent) then
      if config.debug then log("ZZZ Restoring PARENT for idx=%d %s => %s == %s(idx=%d)", x.idx, type, x.restoreParent, x.parent.type, x.parent.idx) end
      stree.current = x.restoreParent
      x.restoreParent = nil
   else
      stree.current = x.parent
   end
end

local function addLastLink(parts)
   local p = parts or false
   if (stree.current.relObj == nil) then stree.current.relObj = {} end
   table.insert(stree.current.relObj, writer.addLastLink(p))
end

-- where pdf objects on its own are used, they later need an entry in ParentTree
-- func gives index of new entry back and puts current there + flag 'discrete'
-- reserved entries for pages range from 1-lastpage, nextparent starts from lastpage + 1
-- /StructParents start at 0 or 1 ???? PDF-Reference Page 570 has 0, distiller starts with 1
-- lets choose 1!
local function getStructParent()
   if (nextparent == nil) then
      -- try the same as in buildpage
      nextparent = ltpdfa.lastpage
      log("GETSTRUCTPARENT CALLED BEFORE ANY PAGE-PARENT EXISTS line %d/-1\n", tex.inputlineno)
   end
   -- increment nextparent
   nextparent = nextparent + 1
   if config.debug then log("GETSTRUCTPARENT line %d/%d", tex.inputlineno, nextparent) end
   stree.parenttree[nextparent] = stree.current
   stree.current.discrete = true
   tex.print(nextparent)
end

local function posToFile(fig, index)
   local tmp = "pos_[" .. index .. "] = {"
   local tmpa = ""
   local fbox = fig.fbox ; local ppos = fig.ppos
   for k,v in pairs(fbox) do
      if k ~= "parent" then
         tmp = tmp .. k .. "=" .. v * spbp_sc .. ", "
      end
   end
   tmpa = "ppos = {"
   for k,v in pairs(ppos) do
      tmpa = tmpa .. k .. "=" .. string.format("%.2f",(v * spbp_sc)) .. ", "
   end
   tmpa = tmpa .. "}"
   posoutfile:write(tmp, "\n\t  ", tmpa , "}\n")
end

--1in + tex.topmargin + tex.headheight + tex.headsep
-- TODO warn/error if on different pages!!!
local posmax
local function readPosStart(index)
   -- tex.pageheight must be correct
   posmax = tex.pageheight
   local x, y = pdf.getpos()
   local fig = figures[index]
   log("READPOS TA %.2f", sptobp(posmax - y))
   if fig then -- could be from artifact
       fig['ppos'] = {}
       fig['ppos']['x1'] = x;
       fig['ppos']['y1'] = y;
       -- fig['ppos']['y1'] = posmax - y
   end
   if config.debug then
      log("READPOS START on page %d => %f/%f for image %d posmax=%.2f", status.total_pages + 1, x/65536.0, y/65536.0, index, sptobp(posmax))
      -- log("pageheight=%.2f voffset=%.2f", sptobp(tex.pageheight), sptobp(tex.voffset))
   end
end

local function readPosEnd(index)
   local x, y = pdf.getpos()
   local fig = figures[index]
   log("READPOS TE %.2f", sptobp(posmax - y))
   if fig then -- could be from artifact
       fig['ppos']['x2'] = x;
       fig['ppos']['y2'] = y;
       -- fig['ppos']['y2'] = posmax - y
   posToFile(fig, index)
   end
   if config.debug then log("READPOS END on page %d => %f/%f for image %d", status.total_pages + 1, x/65536.0, y/65536.0, index) end
end

local function readPosFile()
   local f, err = loadfile(posfile)
   -- afterwards overwrite
   posoutfile = io.open(posfile, 'w+')
   posoutfile:write('local pos_ = {}\n')
   local x = {}
   if f == nil then
      log("Warning: Could not read position file!")
      return false
   else
      x = f()
   end
   -- TODO convert to sp
   positions = x
   return true
end

local function closePosFile()
   posoutfile:write('\nreturn pos_\n')
   posoutfile:close()
end

local function markPara(head, context)
   log("markPara groupcode=%s", context)
   local tail = node.tail(head)
   return writer.markPara(head, tail, context)
end

--[[
   remove current struct from tree
   only works correctly if no content has been added ...
   autoclose structs???
--]]
local function structRemove()
   local x = stree.current
   if (stree.current.idx == 1) then
      -- never close idx=1
      log("Not willing to remove idx=1 open (%s)", x.type)
      return
   end
   x.parent:removeChild(x)
   removed = x
   if (x.restoreParent) then
      stree.current = x.restoreParent
      x.restoreParent = nil
   else
      stree.current = x.parent
   end
   log("removed current: %s now %s", x.type, stree.current.type)
end

local function getCurrentStruct(key)
   local key = key
   tex.print(stree.current[key])
end

local function addToStruct(idx)
   local idx = tonumber(idx)
   local selem = stree.structarray[idx]
   stree.current.restoreParent = stree.current.parent
   stree.current.parent:removeChild(stree.current)
   stree.current.parent = selem
   table.insert(selem.childs, stree.current)
end

local function ignoreNext(sname)
   ignore = sname
end

local function setWriter(iwriter)
   writer = iwriter
end

local function pushStruct(idx)
   local idx = tonumber(idx)
   stree.current = stree.structarray[idx]
   if config.debug then
      log("pushStruct %s", idx)
      dumpArray(stree.current)
   end
end

local structtree = { -- module table
   sptobp           = sptobp,
   structEnd        = structEnd,
   structStart      = structStart,
   addToStruct      = addToStruct,
   pageprocessor    = buildpage,
   stree            = stree,
   dumpStructs      = dumpStructs,
   addLastLink      = addLastLink,
   getStructParent  = getStructParent,
   readPosStart     = readPosStart,
   readPosEnd       = readPosEnd,
   savePosStart     = savePosStart,
   savePosEnd       = savePosEnd,
   figureSet        = figureSet,
   finalizeDoc      = finalizeDoc,
   readPosFile      = readPosFile,
   closePosFile     = closePosFile,
   markPara         = markPara,
   structRemove     = structRemove,
   getCurrentStruct = getCurrentStruct,
   ignoreNext       = ignoreNext,
   setWriter        = setWriter,
   pushStruct       = pushStruct,
   addFigure        = addFigure,
}

return structtree

--[[
   Grouping Elements:
   Document, Part, Art, Sect, Div, BlockQuote, Caption, TOC, TOCI, Index, NonStruct, Private

   Block-Level-Elements:
   P, H, H1-H6, L, Lbl, LI, LBody, Table

   Inline-Level-Elements:
   Span, Quote, Note, Reference, BibEntry, Code, Link, Annot, Ruby, Warichu

   Illustration-Elements:
   Figure, Formula, Form

   after \end{document} noch
   STRUCTTREE.CLOSE document next=StructRoot
   ltpdfa.endDocument
   STRUCTTREE.OPEN header current=StructRoot table: 0x2a22310
   STRUCTTREE.CLOSE header next=StructRoot

   Document -> P -> Link -> [MCR(Link) + Link Annotation]
   Document -> P -> Link -> [MCR(Link) + Link Annotation]

   ParentTree needs entries of
   number = value of /StructParent(s)
   value  =
   1.) if Pagecontent array of references to StructElem
   2.) content items on its own (PDF-objects) indirect reference to its enclosing StructElem

   footnote => <P>The first idea<Reference><Lbl>1</Lbl></Reference> <Note><Lbl>1</Lbl>) The first idea is to
   understand footnotes</Note> for the first footnote on this page, the second
   Note elems wants ID!!!

   Obviously PAC checks nesting for some Inline elements => Grouping -> Block -> Inline

   BBox:
   (Optional for Annot; required for any figure or table appearing in its
   entirety on a single page; not inheritable) An array of four numbers in
   !!! default user space units !!! that shall give the coordinates of the left,
   bottom, right, and top edges, respectively, of the element’s bounding
   box (the rectangle that completely encloses its visible content). This
   attribute shall apply to any element that lies on a single page and
   occupies a single rectangle.

--]]
