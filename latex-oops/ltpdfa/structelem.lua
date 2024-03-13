--[[
   contains the StructElem class and code 
--]]
local config = ltpdfa.config
local structelem = {}

-- define structelem class
StructElem = {
   type    = "UNKNOWN", -- type name 
   -- actualtext
   -- actpara -- is an autopara active?
   -- altText,
   -- attributes, -- attr with /O /Layout values are complete pdf strings
   -- childs  = {},  -- child elements (other or content)
   -- class,
   -- created -- is created at writer level
   -- endpage
   -- idx
   -- ID typename + idx as string
   -- isArtifact
   -- lang, TODO
   -- lastUsed -- last added child selem MCID in .childs
   -- optional
   -- parent  = 0,  -- parent element (indirect)
   -- restoreParent
   -- startpage    = -1, -- reference to page object
   -- title,
   -- type
   -- ltype structure type BLSE, Grouping, ILSE
   -- forced -- has it forcefully put into specified parent element/optparent 
}
StructElem.__index = StructElem -- fallback to the class table, to get methods
-- create StructElem
-- arg type = string
function StructElem:new(type)
   -- TODO copy from prototype ???
   elem = {}
   elem.type = type
   elem.idx = structelem.stree.count
   setmetatable(elem, self)
   elem.childs    = {}
   elem.parent    = 0
   elem.startpage = 0
   elem.lastUsed  = 0 -- remember last child, some mcid was added
   elem.created   = false
   return elem
end
-- remove child or nothing, return next free
function StructElem:removeChild(child)
   local idx = 0
   for k,v in pairs(self.childs) do
      if (child == v) then
         idx = k
         table.remove(self.childs, idx)
         break
      end
   end
   return idx + 1
end
-- propagate lastUsed to parents
function StructElem:adjustInsert()
   local newparent = self.parent
   local last = self
   while (newparent) do
      if (newparent.idx) == 0 then break end
      newparent.lastUsed = last
      last = newparent
      newparent = newparent.parent
   end
   return false
end
-- searches idx in selem, where in childlist to insert
-- skips over earlier forced into parent structs after searching
function StructElem:findInsert()
   local idx = 0
   local childs = self.childs
   for k,v in pairs(childs) do
      if (self.lastUsed == v) then
         idx = k
         break
      end
   end
   -- -- skip over forced following found
   -- for i = idx + 1, #childs - 1 do
   --    log("Skipping insert at %i with %s %s", i, childs[i].type, childs[i].forced)
   --    if childs[i].forced then
   --       idx = i
   --    else
   --       break
   --    end
   -- end
   return idx + 1
end
function StructElem:addMCID(mcid)
   -- do not add artifacts into childs
   if (self.isArtifact) then return end
   local selem = self
   -- if (selem.actpara) then selem = selem.actpara end
   local idx = selem:findInsert()
   --log("findInsert(addMCID) => %s %s/%s", idx, self, selem)
   table.insert(selem.childs, idx, {mcid = mcid, startpage = status.total_pages + 1})
   selem.lastUsed = selem.childs[idx]
   selem:adjustInsert()
   --dumpStructs(self, 0)
   if config.debug then log("ADDMCID %s mcid=%d idx=%d type=%s lastUsed=%s",selem.childs, mcid, selem.idx, selem.type, selem.lastUsed) end
   return idx
end
function StructElem:forceParent(optparent)
   --log("FORCEPARENT for idx=%d parent=%s",self.idx, self.parent)
   --dumpArray(self)
   local newparent = self.parent
   while (newparent) do
      if (newparent.type == optparent) then
         self.parent = newparent
         self.forced = true
         --log("NEWPARENT %d",newparent.idx)
         return true
      end
      newparent = newparent.parent
   end
   return false
end
-- TODO after sectionhead, close paras
function StructElem:closePara()
   -- if (self.type == 'autopara') then
   --    if (structtree.current.idx == 1) then
   --       -- never close idx=1
   --       log("Keeping idx=1 open (%s)", x.type)
   --       return
   --    end
   --    self.endpage = status.total_pages + 1
   --    structtree.current = self.parent
   --    structtree.current.actPara = false
   --    -- lastUsed ???
   -- end
end

-- function StructElem:addPara(forced)
--    if (self.type == 'autopara') then self:closePara() end -- TODO
--    structelem.stree.count = structelem.stree.count + 1
--    local x = StructElem:new('autopara')
--    structelem.stree.structarray[x.idx] = x -- no page content can match this
--    x.isArtifact = false
--    x.ID = 'autopara' .. x.idx .. self.type -- default ID
--    x.ltype = 0
--    x.parent = self
--    x.startpage = status.total_pages + 1
--    if forced then x.forced = true end
--    local idx = self:findInsert()
--    table.insert(x.parent.childs, idx, x)
--    self.lastUsed = x
--    self.actpara = x
--    self:adjustInsert()
--    structelem.stree.current = x
--    return idx
-- end

function StructElem:addToAttributes(key, arg)
   if self.attributes == nil then
      self.attributes = {}
   end
   if self.attributes[key] == nil then
      self.attributes[key] = {}
   end
   table.insert(self.attributes[key], arg)
   --log("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ %s", self.idx)
   --dumpArray(self.attributes.Table)
end

function StructElem:hasContentChilds()
   -- look for childs with mcid
   for k,v in pairs(self.childs) do
      if (v.mcid) then
         return true
      end
   end
   return false
end

return structelem
