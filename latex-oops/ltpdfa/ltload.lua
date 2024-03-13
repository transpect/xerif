-- try to safe searcher for ascii85.so
-- setup_lua_path has been called before
print("dump of %s", package.searchers)
for k,v in pairs(package.searchers) do
   print(k, v)
end

_G['kpse_clua_searcher'] = package.searchers[3]
print ("searchers3 %s/%s/%s", package.searchers[3], _G['kpse_clua_searcher'], _G)
-- found by comparing with and without --shell-escape
-- call like this lualatex --lua=ltpdfa/ltload.lua test.tex
