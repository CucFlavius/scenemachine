using Newtonsoft.Json;

namespace DataGenerator
{
    public class DirEntry
    {
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Dictionary<string, DirEntry>? dirs;
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Dictionary<string, uint>? files;
    }
}
