using DBCD.Providers;

namespace DataGenerator
{
    public class DBDProvider : IDBDProvider
    {
        private static Uri baseURI = new Uri(@"https://raw.githubusercontent.com/wowdev/WoWDBDefs/master/definitions/");
        private HttpClient client = new HttpClient();

        public DBDProvider()
        {
            client.BaseAddress = baseURI;
        }

        public Stream StreamForTableName(string tableName, string build = null)
        {
            var dbdName = Path.GetFileName(tableName).Replace(".db2", ".dbd");
            Console.WriteLine(dbdName);
            var bytes = client.GetByteArrayAsync(dbdName).Result;
            return new MemoryStream(bytes);
        }
    }
}