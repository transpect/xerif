local a_glyph = node.id("glyph")
local a_disc = node.id("disc")
local a_glue = node.id("glue")
local a_kern = node.id("kern")
local a_penalty = node.id("penalty")
local a_hlist = node.id("hlist")
local a_vlist = node.id("vlist")
local a_whatsit = node.id("whatsit")
local a_local_par = node.id("local_par")

local config    = ltpdfa.config
local writer    = ltpdfa.odriver
local line      = 0
local lastGlyph = {
   -- use \exhyphenchar ???
   cumulated = 0 -- cumulated space after
}

local dummyfontspec = ""
if config.driver == "dvips" or config.driver == "distps" then
--[[
   best we can ever achieve
   - have pfb with a space glyph
   - get char 32 or whatever for explicit space into dvi
   - have a line in psfonts.map or friends with an encoding vector charcode => 'space'
     dvips.enc, 8r.enc, 8a.enc, ansinew.enc, lm-texnansi.enc
   - somehow manage ToUnicode mapping
--]]   
   dummyfontspec = 'file:dummy-space.tfm:pfbfile=dummy-space.pfb;mode=node;reencode=dummyspace.enc'
   dummyfontspec = 'file:texnansi-lmr10.tfm:pfbfile=lmr10.pfb;mode=node' -- error !!!!;reencode=dummyspace.enc
else
   dummyfontspec = "LMRoman10-Regular"   
end

local dummyfontchar = 32
local dummyfontsize = 10
local dummyfont = nil
local dummyfontid = 0
local spaceglyph = nil
local spacekern = nil

local function dumpFonts(fontname)
   for i,v in font.each() do
      log("dumpFont: %d", i)
      dumpArray(v)
      if (v == fontname) then
         return true
      end
   end
   -- local loaded = luaotfload.aux.get_loaded_fonts({ 'fullname', 'fontname', 'psname', 'filename' }) -- table of fieldnames
   -- dumpArray(loaded, true)
   -- fonts.definers.registered(), fonts.definers.register
   return false
end
-- GS_FONTPATH=/home/axel/projects/din/DIN_ISO_16962/pdfa/ gs -DBATCH -dNODISPLAY myprfont.ps 
local function createDummyFont()
   log("CREATEDUMMYFONT")
   --pdf.mapline('+' .. dummyfontname .. ' <' .. dummyfontname .. '.pfb')
   if luaotfload then -- luaotfloader
      -- need reencode here for getting => tounicode = 1
      -- local tfmdata = fonts.definers.read("file:" .. dummyfontname .. '.tfm:mode=node;reencode=dummyspace.enc', dummyfontsize*2^16) --sp points
      local tfmdata = fonts.definers.read(dummyfontspec, dummyfontsize*2^16) --sp points
      dummyfontid = font.define(tfmdata)
      dummyfont = tfmdata -- or fonts.hashes.identifiers[id] or font.fonts[dummyfontid] ???
   else
      log("Error: could not create Dummyfont - THIS IS LEFT TODO")
   end
   dummyfont.characters[dummyfontchar].width=0
   dummyfont.characters[dummyfontchar].height=0
   dummyfont.characters[dummyfontchar].depth=0
   spaceglyph = node.new(a_glyph, 0) -- type = glyph, subtype = character
   spaceglyph.char = dummyfontchar
   spaceglyph.font = dummyfontid
   spacekern = node.new(a_kern, 1) -- type = kern, subtype = userkern
   spacekern.kern = -spaceglyph.width
   if config.debug then
      log("getDummyFont created (%d):", dummyfontid)
      dumpArray(dummyfont)
      log("width of dummy template %d",spaceglyph.width)
      log("dummy char")
      dumpArray(dummyfont.characters, true)
   end
end

-- version that should safely work with luaotfloader
-- setting width does not help against visible changes
-- we need a font/char with it or skip back after insertion ??? TODO
local function mygetfont(id)
   local f = fonts.hashes.identifiers[id]
   if f then
      return f
   end
   return font.fonts[id]
end

-- change for debugging
local function setDebug()
   dummyfontname = 'cmtt10'
   dummyfontchar = 32
   dummyfontsize = 10
   local tfmdata = font.read_tfm(dummyfontname .. '.tfm',dummyfontsize*2^16)
   dummyfontid = font.define(tfmdata)
   dummyfont = tfmdata
   spaceglyph = node.new(a_glyph, 0)
   spaceglyph.char = dummyfontchar
   spaceglyph.font = dummyfontid
   spacekern = node.new(a_kern, 1)
   spacekern.kern = -spaceglyph.width
   if config.debug then
      log("getDummyFont created (%d/%s):", dummyfontid, dummyfontname)
      dumpArray(dummyfont)
      log("width of dummy template %d",spaceglyph.width)
   end
end

local function cleanUp()
   node.free(spaceglyph)
   node.free(spacekern)
end

-- TODO hyphenation disc subtype regular at end of line without subcomponents ???
-- TODO process ligatures here too => glyph(subtype ghost + components field), disc with replace|pre|post
-- TODO respect leaders
local function processLine(head, hmode, lastbox)
   -- look for rightskip(9 ends line), spaceskip(13), parfillskip(15), margin_kern???
   -- what about tabskip(12), xspaceskip(14) ???
   -- break at lineskip ??
   -- log("\t\tprocessLine %s %d", head, line)
   if config.debug then log("\tspaceprocessor.processLine %s %d", head, line) end
   for curr in node.traverse(head) do
      -- check if lastGlyph left and new line
      if (lastGlyph.node and lastGlyph.line ~= line) then
         --log("OTHWERWISE LOST SPACE %s in %d/%d hmode=%d (%s)", (node.types())[curr.id], lastGlyph.line, line, hmode, lastGlyph.node.char)
         lastGlyph = {cumulated = 0}
      end
      --log("processLine %s in %d hmode=%d", (node.types())[curr.id], line, hmode)
      if (curr.id == a_glyph) then
         --log("\t\t\tGLYPH %s", curr.char)
         local f = mygetfont(curr.font) -- aerger mit luaotfload font.fonts[curr.font]
         lastGlyph.font = f
         lastGlyph.node = curr
         lastGlyph.minspace = f.parameters.space - f.parameters.space_shrink
         lastGlyph.line = line
         lastGlyph.head = head
         lastGlyph.cumulated = 0
         lastGlyph.hyphenation = false
         local next = curr.next
         if (next and next.id == a_disc) then
            -- TODO check glyph for \exhyphenchar???
            if (next.subtype == 3 and next.pre == nil and next.post == nil and next.replace == nil) then
               lastGlyph.hyphenation = true
               lastGlyph = {cumulated = 0}
               -- do we need to close current BDC/EMC and reopen afterwards ???
               writer.hyphenation(head, curr)
            end
         end
      elseif (curr.subtype == 3 and curr.id == a_disc and curr.pre == nil and curr.post == nil and curr.replace == nil) then
         -- hyphenation is glyph follwed by disc subtype regular no pre,post,replace
         if config.debug then log("\t\t\tHYPHENATION") end
      elseif (curr.id == a_hlist or curr.id == a_vlist) then
         local hmode = 1
         if (curr.id == a_vlist) then hmode = 0 end
         --log("\t\t\t(V|H)LIST %s XX %s", curr, curr.list)
         -- if (curr.subtype == 1) then
         --    --line = line + 1
         --    if config.debug then
         --       log("\tspaceprocessor.markLine(sub) %s", curr)
         --       writer.markLine(lastbox, curr) -- TODO config.showspaces
         --       -- maybe lastbox.list has changed
         --       log("\tspaceprocessor.markedLine(sub) %s", curr)
         --    end
         -- end
         processLine(curr.list, hmode, curr)
      elseif (curr.id == a_glue) then
         -- 9 rightskip, 13 spaceskip, 15 parfillskip, 100 leaders, 101 cleaders, 102 xleaders, 103 gleaders 
         -- these types directly mean space, leaders=100
         -- log("GLUE %d, %s eff. width=%s/%s", curr.subtype, curr, width, curr.width)
         if (curr.subtype == 13 or curr.subtype == 9 or curr.subtype == 15 or curr.subtype == 100 or curr.subtype == 101) then
            --log("\t\t\tGLUE %d, %s", curr.subtype, curr)
            if (lastGlyph.node and lastGlyph.hyphenation == false) then
               head, curr = writer.space(head, lastGlyph, spaceglyph, spacekern) 
               lastGlyph = {cumulated = 0}
            end
         -- 0 userskip fil etc.
         elseif (curr.subtype == 0 and hmode) then
            -- hspaces are summed up
            local width = node.effective_glue(curr, lastbox)
            lastGlyph.cumulated = lastGlyph.cumulated + width
            if (lastGlyph.node and lastGlyph.cumulated and (lastGlyph.cumulated > lastGlyph.minspace)) then
               if (lastGlyph.hyphenation == false) then
                  head, curr = writer.space(head, lastGlyph, spaceglyph, spacekern)
                  lastGlyph = {cumulated = 0}
               end
            end
         end
      elseif (curr.id == a_kern and hmode) then
         -- hspaces summed up
         lastGlyph.cumulated = lastGlyph.cumulated + curr.kern
      else
         -- doSpace = true
      end
   end
   --log("\t\t<=processline %s %s %s", groupcode, lastFont, lastGlyph)
   return true
end

-- box should be a vlist or hlist
local function spaceprocessor(box)
   local head = box.list
   if config.debug then log("spaceprocessor.spaceprocessor\n\tbox=%s\n\thead=%s", box, head) end
   for curr in node.traverse(head) do
      if (curr.id == a_hlist) then
         if (curr.subtype == 1) then
            line = line + 1
            -- if config.debug then
            --    log("spaceprocessor.markLine %s", box.list)
            --    writer.markLine(box, curr) -- TODO config.showspaces
            --    -- maybe box.list has changed
            --    log("spaceprocessor.markedLine %s", box.list)
            -- end
         end
         processLine(curr.list, 1, curr)
      elseif (curr.id == a_vlist) then
         spaceprocessor(curr)
      end
   end
   if (lastGlyph.node and lastGlyph.hyphenation == false) then
      --log("SPACEPROCESSOR OTHWERWISE LOST SPACE in %d/%d (%s)", lastGlyph.line, line, string.char(lastGlyph.node.char))
      writer.space(head, lastGlyph, spaceglyph, spacekern)
      lastGlyph = {cumulated = 0}
   end
   return true
end

-- unfortunately the lua callbacks do not cover footer and header ;-(
-- so atbegshi back again
function processpage(box)
   if config.debug then log("spaceprocessor.processpage!!! %s", box) end
   line = 0
   lastGlyph = {cumulated = 0}
   spaceprocessor(box)
   return true
end

spaceproc = {
   processpage = processpage,
   createDummyFont = createDummyFont,
   setDebug = setDebug,
   cleanUp = cleanUp
}
return spaceproc

--[[
diff: fonts.definers.read("file:uplr8a.pfb:mode=base", 42*2^16) -- in scaled points
to CambriaSpace
	 dump of table: 0x3a01d00
	 descriptions => table: 0x39b5430
	 encodingbytes => 2
	 filename => /Daten/texlive/2016/texmf-dist/fonts/type1/urw/palatino/uplr8a.pfb
	 fontname => URWPalladioL-Roma
	 format => type1
	 fullname => URW Palladio L Roman-2
	 goodies => table: 0x3d680c0
	 identity => horizontal
	 nomath => true
	 psname => URW-Palladio-L-Roman
	 resources => table: 0x3ce93c0
	 shared => table: 0x3db7910
	 size => 2752512
	 specification => table: 0x3a018a0
	 tounicode => 1
	 type => real
	 units => 1000
	 units_per_em => 1000
	 unscaled => table: 0x3db7400
	 writingmode => horizontal

fonts =>
  dump of table: 0x2175d30
  tracers => table: 0x344a2b0
  loggers => table: 0x344a580
  constructors => table: 0x344a760
  definers => table: 0x344a500
  names => table: 0x3bf01d0
  tables => table: 0x35728d0
  protrusions => table: 0x3ba6b80
  analyzers => table: 0x344a480
  hashes => table: 0x35727f0
  expansions => table: 0x3ba7080
  specifiers => table: 0x344a2f0
  formats => table: 0x36e02a0
  helpers => table: 0x344a270
  mappings => table: 0x36ceb70
  cid => table: 0x36e19a0
  readers => table: 0x344a4c0
  handlers => table: 0x344a7a0
  encodings => table: 0x36dfe40

fonts.definers =>
  dump of table: 0x27ed2a0
  addlookup => function: 0x2fea270
  registersplit => function: 0x2fea710
  analyze => function: 0x2fea9a0
  getspecification => function: 0x30adaa0
  register => function: 0x2feb330
  !!!! loadfont !!!! => function: 0x2feb080
  methods => table: 0x2805350
  resolve => function: 0x2feacc0
  read => function: 0x2feb380
  defaultlookup => file
  makespecification => function: 0x2fea900
  registered => function: 0x2feb2c0
  applypostprocessors => function: 0x2feaf90
  current => function: 0x2feb260
  resolvers => table: 0x2feaa40

fonts.constructors =>
  dump of table: 0x41901a0
  hashmethods => table: 0x4191710
  setname => function: 0x4191880
  addcoreunicodes => function: 0x41912d0
  checkedfilename => function: 0x41918c0
  initializefeatures => function: 0x4191210
  assignmathparameters => function: 0x4190da0
  !!!! readanddefine !!!! => function: 0x4798550
  aftercopyingcharacters => function: 0x4190e40
  privateoffset => 983040
  designsizes => table: 0x406f680
  cacheintex => true
  finalize => function: 0x41916a0
  namemode => fullpath
  enhancers => table: 0x4190fd0
  factor => 65536
  scale => function: 0x3cfb280
  scaled => function: 0x4190c90
  newfeatures => table: 0x4191bf0
  setfactor => function: 0x406f740
  cache => table: 0x406f330
  registerfeature => function: 0x4191b30
  autocleanup => true
  checkvirtualids => function: 0x4798520
  resolvevirtualtoo => false
  version => 1.01
  dontembed => table: 0x406f2b0
  applymanipulators => function: 0x4191290
  collectprocessors => function: 0x4191250
  features => table: 0x4191bf0
  newenhancer => table: 0x4190fd0
  newhandler => table: 0x4191e00
  handlers => table: 0x4191e00
  beforecopyingcharacters => function: 0x4190e10
  hashfeatures => function: 0x4191750
  hashinstance => function: 0x412d980
  checkedfeatures => function: 0x41911d0
  calculatescale => function: 0x4190d30
  cleanuptable => function: 0x4190cc0
  enhanceparameters => function: 0x4191480
  getfeatureaction => function: 0x4191b90
  loadedfonts => table: 0x406f6c0
  sharefonts => false
  trytosharefont => function: 0x3f22580
  nofsharedfonts => 0

--]]
