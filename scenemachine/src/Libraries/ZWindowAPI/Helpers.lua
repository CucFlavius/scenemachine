ZWindowAPI = ZWindowAPI or {}

ZWindowAPI.Helpers = ZWindowAPI.Helpers or {};
local WHelpers = ZWindowAPI.Helpers;

WHelpers.SimpleRound = function(val,valStep)
    return floor(val/valStep)*valStep
end