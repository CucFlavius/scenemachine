assert(LibStub, "LibZeeWindowAPI retuires LibStub")

local ZWindowAPI, oldminor = LibStub:NewLibrary("LibZeeWindowAPI", 1)

if not ZWindowAPI then return end
oldminor = oldminor or 0
