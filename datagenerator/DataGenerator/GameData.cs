using CASCLib;
using DBCD;
using System.Diagnostics;

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
