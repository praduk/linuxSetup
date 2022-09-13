-- local ls = require("luasnip")
local available, ls = pcall(require,"luasnip")
if not available then return
end

-- Vim Keybindings for LuaSnip
-- vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
-- vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
-- vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
-- vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

-- LuaSnip Configuration
ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    ext_opts = {
        [require("luasnip.util.types").choiceNode] = {
            active = {
                virt_text = { {"⬤", "GruvboxOrange"} },
            },
        },
    },
})


-- local snip = ls.snippet
-- local node = ls.snippet_node
-- local text = ls.text_node
-- local insert = ls.insert_node
-- local func = ls.function_node
-- local choice = ls.choice_node
-- local dynamicn = ls.dynamic_node

local s = ls.snippet
local n = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node


local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local ne = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

--ls.add_snippets("all", {
--    s("textNodes", {
--        t({"Hello World", "This is another line"}),
--        t({"","",""}),
--        t({"And Two Lines Down"}),
--    }),
--})

local snip = function(ls,languages,snippet)
    for _,language in ipairs(languages) do
        ls.add_snippets(language, {snippet})
    end
end
local autosnip = function(ls,languages,snippet)
    for _,language in ipairs(languages) do
        ls.add_snippets(language, {snippet}, {type = "autosnippets", key="all_auto"})
    end
end


-- Amazon Header
snip(ls,{"c","cpp"},
s({trig="ahdr"},
fmt( [[
/**
 * @file
 * {}
 * @copyright {} Amazon.com Inc. or its afilliates.  All Rights Reserved.
 */


]],{i(1,"Description"),t(os.date("%Y"))})))

--ls.add_snippets("cpp",
--s({trig="ahdr"},
--fmt( [[
--/**
-- * @file
-- * {}
-- * @copyright {} Amazon.com Inc. or its afilliates.  All Rights Reserved.
-- */
--
--
--]],{i(1,"Description"),t(os.date("%Y"))})), {type = "autosnippets", key="all_auto"})

--ls.add_snippets("cpp", {
--s({trig="auto%d%d",regTrig=true},t("auto-generated")),
--},{type = "autosnippets", key="all_auto"})

autosnip(ls,{"cpp"},s({trig="duto%d%d",regTrig=true},t("auto-generated")))





-- C/C++ Sniippets
-- local clangs = {"c", "cpp"}
-- for langindex,language in ipairs(clangs) do
-- -- Snippet to Add Amazon Heaader to a File
-- ls.add_snippets(language, {
-- s(  { trig = "ahdr",
--       name = "Amazon File Header",
--       dscr = "Writes C++ Source File Header Amazon File Header", },
-- fmt( [[
-- /**
--  * @file
--  * {}
--  * @copyright {} Amazon.com Inc. or its afilliates.  All Rights Reserved.
--  */
-- 
-- 
-- ]],{i(1,"Description"),t(os.date("%Y"))})),
-- })
-- end


