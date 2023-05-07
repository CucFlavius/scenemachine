local Win = ZWindowAPI;

function Win.Initialize(rootPath)
    Win.rootPath = rootPath;
    Win.resourcePath = rootPath .. "\\Resources";
    
    Win.fontResourcePath = Win.resourcePath .. "\\font\\";
    Win.fontResources = {}
    Win.fontResources["Segoe"] = Win.fontResourcePath .. "\\Segoe UI.TTF";
    
    Win.textureResourcePath = Win.resourcePath .. "\\image\\";
    Win.textureResources = {}
    Win.textureResources["SliderThumb"] = Win.textureResourcePath .. "\\SliderThumb";

    Win.defaultFont = Win.fontResources["Segoe"];
end