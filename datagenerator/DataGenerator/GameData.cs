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
    }
}
