using System;
using System.Net;
//using Newtonsoft.Json;
using CASCLib;

namespace DataGenerator
{
    internal class Program
    {
        const string ADDON_DATA_PATH = "..\\..\\..\\..\\..\\scenemachine\\res\\data\\";
        const string DATA_FILE_NAME = "data.lua";
        const string ANIMATION_DATA_FILE_NAME = "animdata.lua";
        const string CREATURE_TO_DISPLAY_DATA_FILE_NAME = "creature2display.lua";
        const string CREATURE_DATA_FILE_NAME = "creature.lua";
        const string LISTFILE_URL = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile-withcapitals.csv";
        const string LISTFILE_PATH = "community-listfile-withcapitals.csv";

        static readonly HashSet<string> filterPaths = new HashSet<string>(StringComparer.InvariantCultureIgnoreCase)
        {
            "Root/Cameras",
            "Root/Character",
            "Root/Creature",
            "Root/Interiors",
            "Root/Spell",
            "Root/Test",
        };

        static void Main(string[] args)
        {
            // File-list data
            //DownloadLatestListfile();
            //GenerateAddonModelData();

            // Database data
            string installPath = @"D:\Games\World of Warcraft\";
            string product = "wow"; // wow (release), wowt (ptr)
            GameData data = new GameData(installPath, product, LISTFILE_PATH);
            //data.GenerateAnimationData($"{ADDON_DATA_PATH}\\{ANIMATION_DATA_FILE_NAME}");
            data.GenerateCreatureData($"{ADDON_DATA_PATH}\\{CREATURE_DATA_FILE_NAME}");
            data.GenerateCreatureDisplayData($"{ADDON_DATA_PATH}\\{CREATURE_TO_DISPLAY_DATA_FILE_NAME}");
        }

        static void DownloadLatestListfile()
        {
            using (var client = new WebClient())
            {
                client.DownloadFile(LISTFILE_URL, LISTFILE_PATH);
            }
        }
        
        static void GenerateAddonModelData()
        {
            DirEntry root = new DirEntry();

            //Dictionary<uint, string> listfileData = new Dictionary<uint, string>();
            string[] lines = File.ReadAllLines(LISTFILE_PATH);
            for (int i = 0; i < lines.Length; i++)
            {
                var tokens = lines[i].Split(';');
                var fileIDString = tokens[0];
                var filePath = tokens[1];

                if (filePath.ToLower().EndsWith(".m2"))
                {
                    if (uint.TryParse(fileIDString, out uint fileID))
                    {
                        var pathTokens = filePath.Split('/');
                        Stack<string> breadcrumb = new Stack<string>();

                        for (int j = pathTokens.Length - 1; j >= 0; j--)
                        {
                            breadcrumb.Push(pathTokens[j]);
                        }

                        GenerateNode(ref breadcrumb, root, fileID);
                    }
                }
            }

            using (var sw = new StreamWriter($"{ADDON_DATA_PATH}\\{DATA_FILE_NAME}"))
            {
                sw.WriteLine("SceneMachine.modelData={");
                GenerateLuaTable(sw, root, "Root", "");
                sw.WriteLine("}");
            }
        }

        static void GenerateLuaTable(StreamWriter sw, DirEntry currentDir, string breadCrumb, string depth)
        {
            sw.WriteLine($"{depth}{{");

            var dirname = Path.GetFileNameWithoutExtension(breadCrumb);
            sw.WriteLine($"{depth}[\"N\"]=\"{dirname}\",");

            if (currentDir.files != null && currentDir.files.Count > 0)
            {
                sw.Write($"{depth}[\"FN\"]={{");
                int idx = 0;
                int tot = currentDir.files.Count;
                foreach (var item in currentDir.files)
                {
                    idx++;
                    if (idx == tot)
                        sw.Write($"\"{item.Key}\"");
                    else
                        sw.Write($"\"{item.Key}\",");
                }
                sw.WriteLine($"}},");

                idx = 0;
                sw.Write($"{depth}[\"FI\"]={{");
                foreach (var item in currentDir.files)
                {
                    idx++;
                    if (idx == tot)
                        sw.Write($"{item.Value}");
                    else
                        sw.Write($"{item.Value},");
                }
                sw.WriteLine($"}},");
            }

            if (currentDir.dirs != null && currentDir.dirs.Count > 0)
            {
                sw.WriteLine($"{depth}[\"D\"]={{");
                foreach (var item in currentDir.dirs)
                {
                    if (filterPaths.Contains($"{breadCrumb}/{item.Key}"))
                        continue;

                    GenerateLuaTable(sw, item.Value, $"{breadCrumb}/{item.Key}", depth + "\t");// + "\t"
                }
                sw.WriteLine($"{depth}}},");
            }

            sw.WriteLine($"{depth}}},");
        }

        static void GenerateNode(ref Stack<string> breadcrumb, DirEntry currentDir, uint fileID)
        {
            if (breadcrumb.Count == 0) return;

            if (breadcrumb.Count == 1)
            {
                // Add file
                string fileName = Path.GetFileNameWithoutExtension(breadcrumb.Pop());

                if (currentDir.files == null)
                    currentDir.files = new Dictionary<string, uint>();

                if (!currentDir.files.ContainsKey(fileName))
                    currentDir.files.Add(fileName, fileID);
            }
            else
            {
                // Add dir
                string dirName = FirstCharToUpper(breadcrumb.Pop());

                if (currentDir.dirs == null)
                    currentDir.dirs = new Dictionary<string, DirEntry>(StringComparer.InvariantCultureIgnoreCase);

                if (!currentDir.dirs.ContainsKey(dirName))
                    currentDir.dirs.Add(dirName, new DirEntry());

                var nextDir = currentDir.dirs[dirName];

                GenerateNode(ref breadcrumb, nextDir, fileID);
            }
        }

        static string FirstCharToUpper(string input) =>
            input switch
            {
                null => throw new ArgumentNullException(nameof(input)),
                "" => throw new ArgumentException($"{nameof(input)} cannot be empty", nameof(input)),
                _ => string.Concat(input[0].ToString().ToUpper(), input.AsSpan(1))
            };

    }
}