local Win = ZWindowAPI;

function Win.Initialize(rootPath)
    Win.rootPath = rootPath;
    Win.resourcePath = rootPath;
    
    Win.fontResourcePath = Win.resourcePath .. "\\font";
    Win.fontResources = {}
    Win.fontResources["Segoe"] = Win.fontResourcePath .. "\\Segoe UI.ttf";
    
    Win.textureResourcePath = Win.resourcePath .. "\\image";
    Win.textureResources = {}
    Win.textureResources["SliderThumb"] = Win.textureResourcePath .. "\\SliderThumb.png";

    Win.defaultFont = Win.fontResources["Segoe"];

    Win.closeWindowText = nil;
    Win.closeWindowIcon = Win.textureResourcePath .. "\\closeButton.png"
end