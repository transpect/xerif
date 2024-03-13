--[[
   ! Interface to tex !
   this modules contains code that is called from tex input
   \structstart, \structend, \addAltText and cousins
   It maintains the bdcs table of known structs with its numeric value

   It does this by using structtree modules object and functions. 
   The list of known types is maintained in ltpdfa.bdcs with its attribute value
   the attribute value is set in opening the element and reset by leaving the
   opened texgroup
--]]
-- variables
local config  = ltpdfa.config
local bdcs    = config.bdcs

local structnum = config.structnumstart
local structtree = ltpdfa.structtree
local stree = structtree.stree
local openedarray  = stree.openedarray -- opened autoclose structs
local ftable = lua.get_functions_table()
-- reserve entries for two functions + corresponding calls
-- changed in TL2020/21
local ltpdfa1Idx = 1
local ltpdfa2Idx = 2
if (tex.luatexversion > 111) then
   ltpdfa1Idx = luatexbase.new_luafunction('ltpdfa:structStart')
   ltpdfa2Idx = luatexbase.new_luafunction('ltpdfa:structEnd')
end
local ltpdf1call = '\\begingroup\\luafunction' .. ltpdfa1Idx .. '{}'
local ltpdf2call = '\\luafunction' .. ltpdfa2Idx .. '\\endgroup{}'
local doautoclose = true

local function doAutoClose(name)
   tex.sprint('\\endgroup')
end

-- egroup = false/true => end grouping or not
-- optparent unused
local function autoClose(name, optparent)
   if not doautoclose then return end
   if #openedarray == 0 then return end
   local htype = config.autoclose[name].Type
   local hierarchy = config.autoclose[htype]
   local level = hierarchy[name].Level
   -- search backwards in openedarray and close every elem with higher level
   for i = #openedarray,1,-1 do
      local selem = openedarray[i]
      local elemconf = hierarchy[selem.type]
      -- hierarchy has it and level greater or equal 
      if (elemconf and elemconf.Level >= level) then
         local egroup = config.autoclose[selem.type].Egroup
         log("autoClosing %s (%s) openedarray=%d/%s", name, htype, #openedarray, openedarray[#openedarray].type)
         log("CLOSING %s at %d with idx=%d level=%d/%d with egroup=%s", selem.type, i, selem.idx, elemconf.Level, level, egroup)
         structtree.structEnd(selem.type)
         -- pop/remove
         openedarray[i] = nil -- correct ???
         if (egroup) then doAutoClose(selem) end
         if (elemconf and elemconf.Level == level) then
            break
         end
      else
         -- log("NONMATCH %s at %d with idx=%d level=%d/%d", selem.type, i, selem.idx, elemconf.Level, level)
      end
   end
end

--[[ 
   optparent can only be higher level struct that already exists and is not already closed
   must handle 'autopara' because these are created from nodelist in between
   or close 'autopara' at end of page ????
--]]
-- functions
--[[
   open a new element
   the problem here is tex.print and friends are collected and fed to tex at the end!
   Because we have to rely on the sequence of 
   structStart:
       \bgroup, set attribute
   structEnd:
       \egroup
   we use two helpers
--]]
local function structStart_(name, optparent, doattr, doclose)
   if doclose then
      if (config.autoclose[name]) then
         autoClose(name, optparent)
      end
   end
   -- is it already known or not?
   if (optparent == "") then optparent = nil end
   if (bdcs[name]) then
   else
      bdcs[structnum] = name
      bdcs[name] = structnum
      structnum = structnum + 1
   end
   if doattr then
      tex.setattribute(ltpdfa.typeattr, bdcs[name])
      structtree.structStart(name, structnum, optparent, true)
   else
      structtree.structStart(name, structnum, optparent, false)
   end
   if (config.autoclose[name]) then
      -- push to openedarray
      table.insert(openedarray, stree.current)
   end
   if config.debug then log("structStart_ %s(%s)(%d/%d) optparent=%s(%s) at line=%d  at nest %d", name, stree.current.parent.type, tex.attribute[ltpdfa.typeattr], tex.attribute[ltpdfa.parentattr], optparent, bdcs[optparent], tex.inputlineno, tex.currentgrouplevel) end
   if (optparent and bdcs[optparent] == nil) then  
      log("WARN: unknown optional parent %s", optparent)
   end
end
-- autoclose must be processed before \\begingroup 
local function structStart(name, optparent)
   if (config.autoclose[name]) then
      -- remove with childs from openedarray and do close groups
      autoClose(name, optparent)
   end
   if (optparent == "") then optparent = nil end
   if (bdcs[name]) then
   else
      bdcs[structnum] = name
      bdcs[name] = structnum
      structnum = structnum + 1
   end
   ftable[ltpdfa1Idx] = function() structStart_(name, optparent, true, false) end -- do not autoclose again
   tex.sprint(config.ltpdfCatcode, ltpdf1call) -- without {} sometimes eats next arg
   if config.debug then log("structStart at %d with %s", tex.inputlineno, name) end
end

local function structEnd_(name)
   if (config.autoclose[name]) then
      autoClose(name, optparent)
      -- structtree.structEnd already happened in autoclose
   else
      structtree.structEnd(name)
      if config.debug then log("structEnd_ %s => %s at nest %d", name, stree.current.type, tex.currentgrouplevel) end
   end
end

local function structEnd(name)
   ftable[ltpdfa2Idx] = function() structEnd_(name) end
   tex.sprint(config.ltpdfCatcode, ltpdf2call)
end

-- no grouping and not setting attribute => no content childs at all
local function vstructStart(name, optparent)
   structStart_(name, optparent, true, true)
end

local function vstructEnd(name)
   structEnd_(name)
end

-- no grouping and not setting parent/type attribute => no content childs at all
local function pstructStart(name, optparent)
   structStart_(name, optparent, false, true)
end

local function pstructEnd(name)
   structEnd_(name)
end

local function addAltText(desc)
   stree.current.altText = desc
end

local function addID(id)
   if id == 'auto' then
      stree.current.neededID = stree.current.type .. stree.current.idx
   else
      stree.current.neededID = id
   end
end

-- layout attributes
local function addPlacement(desc)
   stree.current:addToAttributes('Layout','/Placement/' .. desc)
end

-- rolemap
local function addRolemap(key, val)
   stree.rolemap[key] = val
end

local function addColSpan(desc)
   stree.current:addToAttributes('Table','/ColSpan ' .. desc)
end

local function addRowSpan(desc)
   stree.current:addToAttributes('Table','/RowSpan ' .. desc)
end

local function addScope(name)
   stree.current:addToAttributes('Table','/Scope/' .. name)
end

local function addKeep()
   stree.current.keep = true
end

local function addNumbering(name)
   stree.current:addToAttributes('List','/ListNumbering/' .. name)
end

local function figureStart(env)
   env = env or 'no'
   if env == 'start' then
      -- structStart -> structStart_ -> executed only after both calls (savePosStart)
      -- -> wrong parent !!!!
      structStart('Figure', nil)
   end
   structtree.savePosStart(false)
end

local function figureEnd(env)
   structtree.savePosEnd(false)
   env = env or 'no'
   if env == 'close' then
      structEnd('Figure', false)
   end
end

local function figureSet(key, value, unit)
   structtree.figureSet(key, value, unit)
end

-- TODO check
local function dspace()
   -- tex.sprint("{\\attribute", ltpdfa.spaceattr, "=1\\hskip{\\spaceskip}}")
end

-- ISO standard 639, rfc3066,ISO 3166 alpha-2 country codes from [ISO 3166]
local function setLang(lang)
   stree.current.Lang = lang
end

local function structRemove()
   structtree.structRemove()
end

local function ignoreNext(sname)
   structtree.ignoreNext(sname)
end

local function setNewParent(path)
   stree.current.newParent = path
end

local function pushStruct(idx)
   structtree.pushStruct(idx)
end

local function addFigure(llx, lly, urx, ury, rwi, rhi, clip)
   structtree.addFigure(llx, lly, urx, ury, rwi, rhi, clip)
end

-- public part
local inputtagger = {
   addAltText      = addAltText,
   addRolemap      = addRolemap,
   addColSpan      = addColSpan,
   addRowSpan      = addRowSpan,
   addScope        = addScope,
   addKeep         = addKeep,
   addLastLink     = structtree.addLastLink,
   addNumbering    = addNumbering,
   addPlacement    = addPlacement,
   addToStruct     = structtree.addToStruct,
   doautoclose     = doautoclose,
   getCurrentStruct= structtree.getCurrentStruct,
--   dspace          = dspace,
   figureEnd       = figureEnd,
   figureSet       = figureSet,
   figureStart     = figureStart,
   getStructParent = structtree.getStructParent,
   addID           = addID,
   structEnd       = structEnd,
   structStart     = structStart,
   vstructEnd      = vstructEnd,
   vstructStart    = vstructStart, -- without grouping
   pstructEnd      = pstructEnd,
   pstructStart    = pstructStart, -- without grouping, without attribute
   structRemove    = structRemove,
   ignoreNext      = ignoreNext,
   setNewParent    = setNewParent,
   pushStruct      = pushStruct,
   setLang         = setLang,
   addFigure       = addFigure
}

return inputtagger
