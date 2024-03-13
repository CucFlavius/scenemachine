using CASCLib;
using DBCD;
using System.Diagnostics;
using System.Drawing;

namespace DataGenerator
{
    public class GameData
    {
        public static LocaleFlags firstInstalledLocale = LocaleFlags.enUS;
        const string NullExtension = "";
        const string M2Extension = ".m2";
        CASCConfig cascConfig;
        CASCHandler cascHandler;
        WowRootHandler wowRootHandler;
        CASCFolder rootFolder;

        List<int> m2FileIDs;
        Dictionary<int, int> creatureModelDataToFileID;
        Dictionary<int, int> creatureDisplayInfoToCreatureModelData;
        Dictionary<int, int> creatureToDisplayInfo;
        Dictionary<int, string> creatureData;

        private Stopwatch _sw;

        public GameData(string installPath, string product, string listfilePath)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Initializing CASCLib.");
            Console.ResetColor();
            this.cascConfig = CASCConfig.LoadLocalStorageConfig(installPath, product);
            this.cascHandler = CASCHandler.OpenStorage(this.cascConfig);
            this.cascHandler.Root.LoadListFile(listfilePath);
            this.wowRootHandler = this.cascHandler.Root as WowRootHandler;
            this.rootFolder = this.wowRootHandler.SetFlags(firstInstalledLocale, false);
        }

        public void BuildM2FileIDList()
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Build M2 FileID List");
            Console.ResetColor();
            this.m2FileIDs = new List<int>();
            foreach (KeyValuePair<ulong, CASCFile> item in CASCFile.Files)
            {
                string filePath = item.Value.FullName;
                string fileExtension = Path.GetExtension(filePath);

                // Skip unknown files
                if (fileExtension == NullExtension)
                {
                    try
                    {
                        // Try to read the file header, see if it's an M2
                    }
                    catch
                    {

                    }
                }
                else if (fileExtension == M2Extension)
                {
                    this.m2FileIDs.Add(this.wowRootHandler.GetFileDataIdByHash(item.Value.Hash));
                }
            }
        }

        public void GetCreatureModelData()
        {
            this.creatureModelDataToFileID = new Dictionary<int, int>();
            _sw = Stopwatch.StartNew();

            var dbcProvider = new DBCProvider(this.cascHandler.OpenFile(1365368));
            var dbdProvider = new DBDProvider();

            var dbcd = new DBCD.DBCD(dbcProvider, dbdProvider);

            var creatureModelData = dbcd.Load("CreatureModelData.db2");
            _sw.Stop();

            foreach (DBCDRow row in creatureModelData.Values)
            {
                var val = row.FieldAs<int>("FileDataID");
                this.creatureModelDataToFileID.Add(row.ID, val);
            }
            Console.WriteLine("{0} completed in {1}", "Load CreatureModelData.db2", _sw.Elapsed);
        }

        public void GetCreatureDisplayInfo()
        {
            this.creatureDisplayInfoToCreatureModelData = new Dictionary<int, int>();
            _sw = Stopwatch.StartNew();

            var dbcProvider = new DBCProvider(this.cascHandler.OpenFile(1108759));
            var dbdProvider = new DBDProvider();

            var dbcd = new DBCD.DBCD(dbcProvider, dbdProvider);

            var creatureDisplayInfo = dbcd.Load("CreatureDisplayInfo.db2");
            _sw.Stop();

            foreach (DBCDRow row in creatureDisplayInfo.Values)
            {
                var val = row.FieldAs<int>("ModelID");
                this.creatureDisplayInfoToCreatureModelData.Add(row.ID, val);
            }
            Console.WriteLine("{0} completed in {1}", "Load CreatureDisplayInfo.db2", _sw.Elapsed);
        }

        public void GetCreatureData()
        {
            this.creatureData = new Dictionary<int, string>();
            this.creatureToDisplayInfo = new Dictionary<int, int>();
            _sw = Stopwatch.StartNew();

            var dbcProvider = new DBCProvider(this.cascHandler.OpenFile(841631));
            var dbdProvider = new DBDProvider();

            var dbcd = new DBCD.DBCD(dbcProvider, dbdProvider);

            var creatureDisplayInfo = dbcd.Load("Creature.db2");
            _sw.Stop();

            foreach (DBCDRow row in creatureDisplayInfo.Values)
            {
                var val = row.FieldAs<int[]>("DisplayID");
                this.creatureToDisplayInfo.Add(row.ID, val[0]);

                var val2 = row.FieldAs<string>("Name_lang");
                this.creatureData.Add(row.ID, val2);
            }

            Console.WriteLine("{0} completed in {1}", "Load Creature.db2", _sw.Elapsed);
        }

        public void GenerateAnimationData(string outputPath)
        {
            if (m2FileIDs == null)
            {
                BuildM2FileIDList();
            }

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Generate Animation Data");
            Console.ResetColor();
            using var sw = new StreamWriter(outputPath);

            sw.WriteLine("SceneMachine.animationData={");

            for (int i = 0; i < m2FileIDs.Count; i++)
            {
                var fileID = m2FileIDs[i];
                var animData = GetAnimDataFromM2(fileID);

                if (animData == null || animData.Count == 0)
                {
                    continue;
                }

                sw.Write($"[{fileID}]={{");

                for (int a = 0; a < animData?.Count; a++)
                {
                    bool last = a == animData?.Count - 1;
                    sw.Write($"{{{animData[a].Item1},{animData[a].Item2},{animData[a].Item3}}}");
                    if (!last)
                        sw.Write(',');
                }

                sw.WriteLine("},");
            }

            sw.WriteLine("}");
        }

        public void GenerateCreatureDisplayData(string outputPath)
        {
            if (creatureToDisplayInfo == null)
            {
                GetCreatureData();
            }

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Generate Creature To Display Data");
            Console.ResetColor();
            using var sw = new StreamWriter(outputPath);

            sw.WriteLine("SceneMachine.creatureToDisplayID={");

            foreach (var item in creatureToDisplayInfo)
            {
                sw.WriteLine($"[{item.Key}]={item.Value},");
            }

            sw.WriteLine("}");
        }

        public void GenerateCreatureData(string outputPath)
        {
            if (creatureData == null)
            {
                GetCreatureData();
            }

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Generate Creature Data");
            Console.ResetColor();
            using var sw = new StreamWriter(outputPath);

            sw.WriteLine("SceneMachine.creatureData={");

            foreach (var item in creatureData)
            {
                var name = item.Value.Replace('\"', '|');
                sw.WriteLine($"[{item.Key}]=\"{name}\",");
            }

            sw.WriteLine("}");
        }

        public void GenerateLightData(string outputPath)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Generate Light Data");
            Console.ResetColor();
            using var sw = new StreamWriter(outputPath);

            sw.WriteLine("SceneMachine.lightData={");

            foreach (KeyValuePair<ulong, CASCFile> item in CASCFile.Files)
            {
                string filePath = item.Value.FullName;
                string fileExtension = Path.GetExtension(filePath);

                // Skip unknown files
                if (fileExtension == NullExtension)
                {
                    try
                    {
                        // Try to read the file header, see if it's an M2
                    }
                    catch
                    {

                    }
                }
                else if (fileExtension == M2Extension)
                {
                    try
                    {
                        var fileID = this.wowRootHandler.GetFileDataIdByHash(item.Value.Hash);

                        // Determine if it's a light only model
                        using var str = cascHandler.OpenFile(fileID);
                        using var br = new BinaryReader(str);

                        br.BaseStream.Position = 68;
                        uint nVertices = br.ReadUInt32();

                        br.BaseStream.Position = 272;
                        uint nLights = br.ReadUInt32();
                        uint ofsLights = br.ReadUInt32();

                        br.BaseStream.Position = 304;
                        uint nParticleEmitters = br.ReadUInt32();

                        br.BaseStream.Position = ofsLights + 8;

                        ushort lightType = br.ReadUInt16();
                        ushort bone = br.ReadUInt16();
                        float posX = br.ReadSingle();
                        float posY = br.ReadSingle();
                        float posZ = br.ReadSingle();

                        // Ambient color track
                        br.BaseStream.Position += 20;

                        // Ambient intensity track
                        br.BaseStream.Position += 20;

                        // Diffuse color track
                        br.ReadUInt16();    // Interpolation type
                        br.ReadInt16();     // Global seq
                        br.ReadUInt32();    // Timestamps Size
                        br.ReadUInt32();    // Timestamps Offset
                        br.ReadUInt32();    // Values Size
                        var offs = br.ReadUInt32();    // Values Offset

                        br.BaseStream.Position = offs + 8;
                        var nValue = br.ReadUInt32();
                        var nOffs = br.ReadUInt32();

                        br.BaseStream.Position = nOffs + 8;
                        float r = br.ReadSingle();
                        float g = br.ReadSingle();
                        float b = br.ReadSingle();

                        if (nLights > 0 && nVertices == 0 && nParticleEmitters == 0)
                        {
                            sw.WriteLine($"{{[{fileID}]={{{r},{g},{b}}}}},");
                            //Console.WriteLine($"{filePath} {r}, {g}, {b}");
                        }
                        else
                        {
                            continue;
                        }
                    }
                    catch { }
                }
            }

            sw.WriteLine("}");
        }

        List<(ushort, ushort, uint)>? GetAnimDataFromM2(int fileID)
        {
            try
            {
                using var str = cascHandler.OpenFile(fileID);
                using var br = new BinaryReader(str);

                var list = new List<(ushort, ushort, uint)>();

                br.BaseStream.Position = 36;
                uint nAnimations = br.ReadUInt32();
                uint ofsAnimations = br.ReadUInt32() + 8;

                br.BaseStream.Position = ofsAnimations;
                for (int i = 0; i < nAnimations; i++)
                {
                    ushort animID = br.ReadUInt16();
                    ushort subAnimID = br.ReadUInt16();
                    uint lengthMS = br.ReadUInt32();

                    // skip rest
                    br.BaseStream.Position += 56;

                    list.Add((animID, subAnimID, lengthMS));
                }

                return list;
            }
            catch
            {
                return null;
            }
        }
    }
}
