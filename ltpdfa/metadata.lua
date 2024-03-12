--[[
   module metadata:
   responsible for /Info and /Metadata
   values in infoarray (private), funcs in docinfo
   !!! maintained as utf8 and out encoding flag !!!
   - xmp metadata
   - /Info
     -- /Title
     -- /Author
     -- /Subject
     -- /Keywords
     -- /Creator
     -- /Producer
     -- /CreationDate
     -- /ModDate
dates handled here too
/Metadata object has to be written uncompressed
xmphandler
--]]

-- from poppler, Unicodepoints
local pdfDocEncoding = {
  0x0000, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, -- 00
  0xfffd, 0x0009, 0x000a, 0xfffd, 0x000c, 0x000d, 0xfffd, 0xfffd,
  0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, 0xfffd, -- 10
  0x02d8, 0x02c7, 0x02c6, 0x02d9, 0x02dd, 0x02db, 0x02da, 0x02dc,
  0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x0027, -- 20
  0x0028, 0x0029, 0x002a, 0x002b, 0x002c, 0x002d, 0x002e, 0x002f,
  0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037, -- 30
  0x0038, 0x0039, 0x003a, 0x003b, 0x003c, 0x003d, 0x003e, 0x003f,
  0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047, -- 40
  0x0048, 0x0049, 0x004a, 0x004b, 0x004c, 0x004d, 0x004e, 0x004f,
  0x0050, 0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057, -- 50
  0x0058, 0x0059, 0x005a, 0x005b, 0x005c, 0x005d, 0x005e, 0x005f,
  0x0060, 0x0061, 0x0062, 0x0063, 0x0064, 0x0065, 0x0066, 0x0067, -- 60
  0x0068, 0x0069, 0x006a, 0x006b, 0x006c, 0x006d, 0x006e, 0x006f,
  0x0070, 0x0071, 0x0072, 0x0073, 0x0074, 0x0075, 0x0076, 0x0077, -- 70
  0x0078, 0x0079, 0x007a, 0x007b, 0x007c, 0x007d, 0x007e, 0xfffd,
  0x2022, 0x2020, 0x2021, 0x2026, 0x2014, 0x2013, 0x0192, 0x2044, -- 80
  0x2039, 0x203a, 0x2212, 0x2030, 0x201e, 0x201c, 0x201d, 0x2018,
  0x2019, 0x201a, 0x2122, 0xfb01, 0xfb02, 0x0141, 0x0152, 0x0160, -- 90
  0x0178, 0x017d, 0x0131, 0x0142, 0x0153, 0x0161, 0x017e, 0xfffd,
  0x20ac, 0x00a1, 0x00a2, 0x00a3, 0x00a4, 0x00a5, 0x00a6, 0x00a7, -- a0
  0x00a8, 0x00a9, 0x00aa, 0x00ab, 0x00ac, 0xfffd, 0x00ae, 0x00af,
  0x00b0, 0x00b1, 0x00b2, 0x00b3, 0x00b4, 0x00b5, 0x00b6, 0x00b7, -- b0
  0x00b8, 0x00b9, 0x00ba, 0x00bb, 0x00bc, 0x00bd, 0x00be, 0x00bf,
  0x00c0, 0x00c1, 0x00c2, 0x00c3, 0x00c4, 0x00c5, 0x00c6, 0x00c7, -- c0
  0x00c8, 0x00c9, 0x00ca, 0x00cb, 0x00cc, 0x00cd, 0x00ce, 0x00cf,
  0x00d0, 0x00d1, 0x00d2, 0x00d3, 0x00d4, 0x00d5, 0x00d6, 0x00d7, -- d0
  0x00d8, 0x00d9, 0x00da, 0x00db, 0x00dc, 0x00dd, 0x00de, 0x00df,
  0x00e0, 0x00e1, 0x00e2, 0x00e3, 0x00e4, 0x00e5, 0x00e6, 0x00e7, -- e0
  0x00e8, 0x00e9, 0x00ea, 0x00eb, 0x00ec, 0x00ed, 0x00ee, 0x00ef,
  0x00f0, 0x00f1, 0x00f2, 0x00f3, 0x00f4, 0x00f5, 0x00f6, 0x00f7, -- f0
  0x00f8, 0x00f9, 0x00fa, 0x00fb, 0x00fc, 0x00fd, 0x00fe, 0x00ff
}
local config = ltpdfa.config
local xmpbody = ""
-- holds values for /Info pdf object   
local infoarray = nil
local xmphandler  = {}

-- dependencies for infoarray
require("lualibs-lpeg")
require("lualibs-unicode")

-- takes a pdfdoc encoded string and escapes '(',')', '\\'
local function escapePdfString(str)
   if str == nil then return false end
   local bs = string.byte("\\")
   local klo = string.byte("(")
   local klc = string.byte(")")
   local bscnt = 0
   local val = ""
   for idx = 1, #str do
      local b = str:byte(idx)
      if b == bs then
         if bscnt == 1 then
            bscnt = 0 --flop
            val = val .. '\\'
         else
            bscnt = 1 -- flip
            val = val .. '\\'
         end
         --log("BACKSLASH at %d %d:", idx, bscnt)
      elseif (bscnt == 0 and b == klo) then
         bscnt = 0
         val = val .. '\\('
      elseif (bscnt == 0 and b == klc) then
         bscnt = 0
         val = val .. '\\)'
      else
         val = val .. string.char(b)
         bscnt = 0
      end
   end
   return val
end

-- helper reducing utf-8 to pdfdocencoding
local function isDocEncoding(str)
   if str == nil then return false end
   local val = ""
   for c in utf.values(str) do
      if c > 255 then
         return false
      else
         c = pdfDocEncoding[c + 1]
         if c < 128 then
            val = val .. string.char(c)
         else
            val = val .. string.format("\\%.3o", c)
         end
      end
   end
   return escapePdfString(val)
end

local function pdfencToUtf8(str)
   local val = ""
   for idx = 1, #str do
      local c = str:byte(idx)
      val = val .. pdfDocEncoding[c]
   end
   return val
end

-- convert UTF-8 to pdf UTF-16
local function utf8ToUtf16(arg)
   local u16val = utf.utf8_to_utf16_be(arg)
   local val = ""
   for idx = 1, #u16val do
      local c = u16val:byte(idx)
      if c < 33 or c > 126 then
         c = string.format("\\%.3o", c)
         --if c == 40 or c == 41 or c == 92 then
         --   return "\\" .. ch
         -- end
      else
         c = string.char(c)
      end
      val = val .. c
   end
   return val
end
-- convert UTF-16 from hyperref to pdf UTF-8
local function utf16ToUtf8(arg)
   -- unescape octal \xxx
   local val = arg:gsub("\\([0-7][0-7][0-7])", function(k) return string.char(tonumber(k,8)) end)
   local u8val = utf.utf16_to_utf8_be(val)
   --log("decodeutf16 %s\n%s\n%s %d", arg, val, u8val, val:len())
   return u8val
end

--------------------------------------------
local xmphead = [[<?xpacket begin="" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core 5.4-c005 78.147326, 2012/08/23-13:03:03        ">
   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <rdf:Description rdf:about=""
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:xmp="http://ns.adobe.com/xap/1.0/"
            xmlns:pdf="http://ns.adobe.com/pdf/1.3/"
            xmlns:xmpMM="http://ns.adobe.com/xap/1.0/mm/"
            xmlns:pdfuaid="http://www.aiim.org/pdfua/ns/id/"
            xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/"
            xmlns:pdfaExtension="http://www.aiim.org/pdfa/ns/extension/"
            xmlns:pdfaSchema="http://www.aiim.org/pdfa/ns/schema#"
            xmlns:pdfaProperty="http://www.aiim.org/pdfa/ns/property#"
            xmlns:pdfaType="http://www.aiim.org/pdfa/ns/type#"
            xmlns:pdfaField="http://www.aiim.org/pdfa/ns/field#"
            >
]]
local pdfaver = [[      <pdfaid:part>PDFAID:PART</pdfaid:part>
      <pdfaid:conformance>PDFAID:CONFORMANCE</pdfaid:conformance>
]]
local pdfuaid = [[      <pdfuaid:part>PDFUAID:PART</pdfuaid:part>
]]
local xmpschema = [[
         <pdfaExtension:schemas>
            <rdf:Bag>
               <rdf:li rdf:parseType="Resource">
                  <pdfaSchema:namespaceURI>http://ns.adobe.com/pdf/1.3/</pdfaSchema:namespaceURI>
                  <pdfaSchema:prefix>pdf</pdfaSchema:prefix>
                  <pdfaSchema:schema>Adobe PDF Schema</pdfaSchema:schema>
                  <pdfaSchema:property>
                     <rdf:Seq>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>A name object indicating whether the document has been modified to include trapping information</pdfaProperty:description>
                           <pdfaProperty:name>Trapped</pdfaProperty:name>
                           <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                        </rdf:li>
                     </rdf:Seq>
                  </pdfaSchema:property>
               </rdf:li>
               <rdf:li rdf:parseType="Resource">
                  <pdfaSchema:namespaceURI>http://ns.adobe.com/xap/1.0/mm/</pdfaSchema:namespaceURI>
                  <pdfaSchema:prefix>xmpMM</pdfaSchema:prefix>
                  <pdfaSchema:schema>XMP Media Management Schema</pdfaSchema:schema>
                  <pdfaSchema:property>
                     <rdf:Seq>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>UUID based identifier for specific incarnation of a document</pdfaProperty:description>
                           <pdfaProperty:name>InstanceID</pdfaProperty:name>
                           <pdfaProperty:valueType>URI</pdfaProperty:valueType>
                        </rdf:li>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>The common identifier for all versions and renditions of a document.</pdfaProperty:description>
                           <pdfaProperty:name>OriginalDocumentID</pdfaProperty:name>
                           <pdfaProperty:valueType>URI</pdfaProperty:valueType>
                        </rdf:li>
                     </rdf:Seq>
                  </pdfaSchema:property>
               </rdf:li>
               <rdf:li rdf:parseType="Resource">
                  <pdfaSchema:namespaceURI>http://www.aiim.org/pdfa/ns/id/</pdfaSchema:namespaceURI>
                  <pdfaSchema:prefix>pdfaid</pdfaSchema:prefix>
                  <pdfaSchema:schema>PDF/A ID Schema</pdfaSchema:schema>
                  <pdfaSchema:property>
                     <rdf:Seq>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>Part of PDF/A standard</pdfaProperty:description>
                           <pdfaProperty:name>part</pdfaProperty:name>
                           <pdfaProperty:valueType>Integer</pdfaProperty:valueType>
                        </rdf:li>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>Amendment of PDF/A standard</pdfaProperty:description>
                           <pdfaProperty:name>amd</pdfaProperty:name>
                           <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                        </rdf:li>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>Conformance level of PDF/A standard</pdfaProperty:description>
                           <pdfaProperty:name>conformance</pdfaProperty:name>
                           <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                        </rdf:li>
                     </rdf:Seq>
                  </pdfaSchema:property>
               </rdf:li>
               <rdf:li rdf:parseType="Resource">
                  <pdfaSchema:namespaceURI>http://www.aiim.org/pdfua/ns/id/</pdfaSchema:namespaceURI>
                  <pdfaSchema:prefix>pdfuaid</pdfaSchema:prefix>
                  <pdfaSchema:schema>PDF/UA ID Schema</pdfaSchema:schema>
                  <pdfaSchema:property>
                     <rdf:Seq>
                        <rdf:li rdf:parseType="Resource">
                           <pdfaProperty:category>internal</pdfaProperty:category>
                           <pdfaProperty:description>Part of PDF/UA standard</pdfaProperty:description>
                           <pdfaProperty:name>part</pdfaProperty:name>
                           <pdfaProperty:valueType>Open Choice of Integer</pdfaProperty:valueType>
                        </rdf:li>
                     </rdf:Seq>
                  </pdfaSchema:property>
               </rdf:li>
            </rdf:Bag>
         </pdfaExtension:schemas>
]]
local xmptail = [[  </rdf:Description>
</rdf:RDF>
</x:xmpmeta>
]]
-- add 20 lines whitespace at load time
for i=0,20 do
   xmptail = xmptail .. string.rep("  ", 100) .. "\n";
end
xmptail = xmptail .. "<?xpacket end=\"w\"?>\n"

-- stolen from pdftexcmds, get modify date from os
local function filemoddate(filename)
   local foundfile = kpse.find_file(filename, "tex", true)
   if foundfile then
      local date = lfs.attributes(foundfile, "modification")
      return date -- os.time format
   end
   -- bad(?) fallback
   return os.time()
end
-- convert to required pdf date format
local function pdfdate(date)
   local resdate = ""
   if date then
      local d = os.date("*t", date)
      if d.sec >= 60 then
         d.sec = 59
      end
      local u = os.date("!*t", date)
      local off = 60 * (d.hour - u.hour) + d.min - u.min
      if d.year ~= u.year then
         if d.year > u.year then
            off = off + 1440
         else
            off = off - 1440
         end
      elseif d.yday ~= u.yday then
         if d.yday > u.yday then
            off = off + 1440
         else
            off = off - 1440
         end
      end
      local timezone
      if off == 0 then
         timezone = "Z"
      else
         local hours = math.floor(off / 60)
         local mins = math.abs(off - hours * 60)
         timezone = string.format("%+03d'%02d'", hours, mins)
      end
      resdate = string.format("D:%04d%02d%02d%02d%02d%02d%s",
                              d.year, d.month, d.day, d.hour, d.min, d.sec, timezone)
   end
   return resdate
end
-- convert to required xmp date format
local function xmpdate(date)
   local resdate =""
   if date then
      local d = os.date("*t", date)
      if d.sec >= 60 then
         d.sec = 59
      end
      local u = os.date("!*t", date)
      local off = 60 * (d.hour - u.hour) + d.min - u.min
      if d.year ~= u.year then
         if d.year > u.year then
            off = off + 1440
         else
            off = off - 1440
         end
      elseif d.yday ~= u.yday then
         if d.yday > u.yday then
            off = off + 1440
         else
            off = off - 1440
         end
      end
      local timezone
      if off == 0 then
         timezone = "Z"
      else
         local hours = math.floor(off / 60)
         local mins = math.abs(off - hours * 60)
         timezone = string.format("%02d:%02d", hours, mins)
      end
      resdate = string.format("%04d-%02d-%02dT%02d:%02d:%02d+%s",
                              d.year, d.month, d.day, d.hour, d.min, d.sec, timezone)
   end
   return resdate
end

-- xmpmetadata handling
-- always writes jobname.xmp
function xmphandler.fromFile(filename)
    --  Read the file
    local f = io.open(filename, "r")
    local content = f:read("*all")
    f:close()
    -- dates
    local moddate = filemoddate(tex.jobname .. '.tex')
    moddate = xmpdate(moddate)
    if (content:find('<xmp:ModifyDate>')) then
       content = content:gsub('<xmp:ModifyDate>.*</xmp:ModifyDate>', '<xmp:ModifyDate>' .. moddate .. '</xmp:ModifyDate>')
    else
       -- TODO
    end
    if (content:find('<xmp:CreateDate>')) then
       content = content:gsub('<xmp:CreateDate>.*</xmp:CreateDate>', '<xmp:CreateDate>' .. moddate .. '</xmp:CreateDate>')
    else
       -- TODO
    end
    local f = io.open(tex.jobname..'.xmp', "w")
    f:write(content)
    f:close()
    return tex.jobname..'.xmp'
end

-- writes jobname.xmp
-- TODO use config.metadata-table!!! handle encoding other than utf-8
function xmphandler.fromInfo()
   local body = ""
   if (config.metadata.Keywords and config.metadata.Keywords[1] ~= '') then
      body = "<pdf:Keywords>" .. config.metadata.Keywords[1] .. "</pdf:Keywords>\n"
   end
   if (config.metadata.Producer and config.metadata.Producer[1] ~= '') then
      body = body .. "<pdf:Producer>" .. config.metadata.Producer[1] .. "</pdf:Producer>\n"
   end
   -- dates
   local moddate = filemoddate(tex.jobname .. '.tex')
   moddate = xmpdate(moddate)
   body = body .. "<xmp:ModifyDate>" .. moddate .. "</xmp:ModifyDate>\n"
   body = body .. "<xmp:CreateDate>" .. moddate .. "</xmp:CreateDate>\n"
   if (config.metadata.Creator and config.metadata.Creator[1] ~= '') then
      body = body .. "<xmp:CreatorTool>" .. config.metadata.Creator[1] .. "</xmp:CreatorTool>\n"
   end
   -- <xapMM:DocumentID>uuid:3d51d5be-cfbc-11f1-0000-6e4afb5d3d68</xapMM:DocumentID>
   body = body .. "<dc:format>application/pdf</dc:format>\n"
   if (config.metadata.Author and config.metadata.Author[1]) then
      body = body .. "<dc:creator>\n<rdf:Seq>\n<rdf:li>" .. config.metadata.Author[1] .. "</rdf:li>\n</rdf:Seq>\n</dc:creator>\n";
   end
   if (config.metadata.Title and config.metadata.Title[1] ~= '') then
      body = body .. "<dc:title><rdf:Alt>\n<rdf:li xml:lang=\"x-default\">" .. config.metadata.Title[1] .. "</rdf:li>\n</rdf:Alt></dc:title>\n"
   end
   if (config.metadata.Subject and config.metadata.Subject[1] ~= '') then
      body = body .. "<dc:description><rdf:Alt>\n<rdf:li xml:lang='x-default'>" .. config.metadata.Subject[1] .. "</rdf:li>\n</rdf:Alt></dc:description>\n"
   end
   if config.metadata.conformance then
      pdfaver = pdfaver:gsub('PDFAID:PART', config.metadata.conformance.pdfaid)   
      pdfaver = pdfaver:gsub('PDFAID:CONFORMANCE', config.metadata.conformance.level)
      if (config.metadata.conformance.pdfuaid) then
         pdfuaid = pdfuaid:gsub('PDFUAID:PART', config.metadata.conformance.pdfuaid)
         pdfaver = pdfaver .. pdfuaid
      end
   end
   local f = io.open(tex.jobname..'.xmp', "w")
   f:write(xmphead .. pdfaver .. body .. xmpschema .. xmptail)
   f:close()
   return tex.jobname..'.xmp'
end

--[[
   public/exported
]]--
-- 'import' values into infoarray => as utf-8
local function fillDocInfo()
   infoarray = {}
   local moddate = filemoddate(tex.jobname .. '.tex')
   moddate = pdfdate(moddate)
   infoarray['CreationDate'] = {moddate, 'pdfdoc'}
   infoarray['ModDate'] = {moddate, 'pdfdoc'}
   for key, val in pairs(config.metadata) do
      local str = val[1]
      local enc = val[2]
      local tmp;
      local newenc;
      if (key ~= 'xmpfile') then
         if (enc == 'utf-8') then
            tmp = isDocEncoding(str) -- false or string
            if tmp then
               newenc = 'pdfdoc'
            else
               tmp = str
               newenc = enc
            end
            --      elseif (enc == 'latin-1') then
            --         tmp = latin1ToUtf8(str) -- to utf-8
         elseif (enc == 'utf-16') then
            str = utf16ToUtf8(str) -- to utf8
            tmp = isDocEncoding(str) -- false or string
            if tmp then
               newenc = 'pdfdoc'
            else
               tmp = str
               newenc = 'utf-8'
            end
         elseif (enc == 'literal') then
            tmp = str -- unchanged
            newenc = 'literal'
         else
            log("WARN: don't know how to handle this encoding for docinfo key %s (%s)", key, enc)
         end
         infoarray[key] = {tmp, newenc}
      end
   end
   if config.debug then
      log("Docinfo:")
      dumpArray(infoarray, true)
   end
end
-- return new array with suitable pdf-encoded vals
local function getDocInfo()
   fillDocInfo()
   local info = {}
   for name, val in pairs(infoarray) do
      if name ~= 'conformance' then
         local enc = val[2]
         local str = val[1]
         if (enc == 'utf-8' or enc == 'utf-16') then
            -- if config.debug then log("RECODE %s, %s => %s", enc, name, str) end
            info[name] = utf8ToUtf16(str)
         elseif (enc == 'pdfdoc' or enc == 'literal') then
            -- if config.debug then log("NO RECODE %s, %s => %s", enc, name, str) end
            info[name] = str
         else
            info[name] = str -- and hope the best
         end
      end
   end
   if config.debug then
      log("Docinfo for pdf:")
      dumpArray(info)
   end
   return info
end

-- file must be utf-8

local metadata = {
   getDocInfo = getDocInfo,
   xmphandler = xmphandler,
}
return metadata

--[[
ghostscript has -dPDFA switch that write metadata as text and ???
    <rdf:Description rdf:about=""
		     xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/">
      <pdfaid:part>1</pdfaid:part>
      <pdfaid:conformance>B</pdfaid:conformance>
    </rdf:Description>
]]--
