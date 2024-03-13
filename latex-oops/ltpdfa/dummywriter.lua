--[[
This is the dummy output driver 
--]]
local function init()
   log("dummywriter init")
end
local function createStruct(head, curr, sparent)
   log("dummywriter createStruct")
end
local function beginMC(head, curr, val, mcid, isArtifact, attributes)
   log("dummywriter beginMC")
   return head
end
local function endMC(head, curr, val, after)
   log("dummywriter endMC")
   return head
end

local function  structParent(head, tail, page)
   log("dummywriter structParent")
end
local function closeElem()
   log("dummywriter closeElem")
end

local writer = {
   init = init,
   -- -- addToUnicode = dviaddToUnicode,
   -- space        = pdfspace,
   -- hyphenation  = pdfhyphenation,
   beginMC        = beginMC,
   createStruct   = createStruct,
   closeElem = closeElem,
   endMC        = endMC,
   -- intent       = pdfintent,
   -- xmpdata      = pdfxmp,
   -- docinfo      = pdfdocinfo,
   -- doclang      = doclang,
   -- structtree   = pdfstructtree,
   structParent = structParent,
   -- parenttree   = pdfparenttree,
   -- rolemap      = pdfrolemap,
   -- addLastLink  = addLastLink,
   -- savepos      = pdfsavepos
}
return writer
