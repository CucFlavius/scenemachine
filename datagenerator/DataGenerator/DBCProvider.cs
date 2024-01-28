using DBCD.Providers;

namespace DataGenerator
{
    class DBCProvider : IDBCProvider
    {
        private Stream stream;

        public DBCProvider(Stream stream)
        {
            this.stream = stream;
        }

        public Stream StreamForTableName(string tableName, string build)
        {
            return stream;
        }
    }
}