# Scene Machine
 A WoW addon that lets you put together scenes using in game models.
![mainscreenshot](/docs/screenshots/02.jpg?raw=true)

### Installation
- Manually:
Simply download the latest release zip file [here](https://github.com/CucFlavius/scenemachine/releases) and extract it into your World of Warcraft addons folder.
- Automatically:
Using CurseForge, look for Scene Machine and it will automatically install the addon and keep it up to date. Or get it from [CurseForge](https://www.curseforge.com/wow/addons/scene-machine)
(Later on I'll make the addon available on other addon distribution platforms)

### How to use, a quick guide
- To open Scene Machine, find the small icon around your minimap and click it;
![howToRun](/docs/screenshots/HowToRun.png?raw=true)
- You will be greeted by the main "Editor" window, with a blank gray scene.
![freshNewWindow](/docs/screenshots/FreshNewWindow.png?raw=true)
    - The gray frame in the center is the scene frame, this is the canvas where you will be crafting your scene.
    - On the left side there are 2 panels: 
        - Hierarchy - will display a list of all objects in the scene (currently empty)
        - Properties - allows you to modify different properties of selected objects, or the scene itself
    - On the right side is the Asset Explorer, where you will find all of the available models, and creatures in the data
    - Bottom side are the Timelines, where you will be able to animate objects. (This feature is still being worked on so this guid won't cover it)

- Scene navigation is simple, it follows WoW's flying controls. Simply use WASD to move around, and hold the right mouse button to point the camera. (You can find all the keys below)
- But first let's load some objects into the scene so we can see where we're going:
- Starting off with the Asset Explorer, you have 2 tabs of interest at the moment
    - Models tab: allows you to browse through the game's folder structure to find any model that you need, bee it a chair, a tree, a skybox, or a light source
    - Creatures tab: will contain a list of all available creatures
    (remember: you can also search through the models and creatures list, at the top)
- The easiest way to load in models is to simply drag them from the asset explorer and into the scene
![dragObjectIn](/docs/screenshots/dragObjectIn.gif?raw=true)
(the same applies for creatures)

- Once you have an object in your scene, you're able to further position/rotate/scale it by enabling the right tool
- To pick a tool: go to the toolbar and choose between select/move/rotate/scale, or right click anywhere in the scene and choose from the context menu, or use one of the keybinds below
![transformTools](/docs/screenshots/transformTools.png?raw=true)
![moveRotateScale](/docs/screenshots/moveRotateScale.gif?raw=true)

These are the absolute basics to get you started. More in depth guides and tricks will follow sometime soon.

### Keyboard Shortcuts
![keyboardShortcuts](/scenemachine/res/textures/keyboardShortcuts.png)

### Important Notes
- Some features such as the animation system are still work in progress. There will be some refactoring done so any animation data saved may be lost.

### More Screenshots
![screenshot1](/docs/screenshots/03.jpg?raw=true)
![screenshot2](/docs/screenshots/04.jpg?raw=true)