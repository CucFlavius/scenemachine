using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LocalizationTool
{
    public class KeyBlock
    {
        string name { get; }
        Dictionary<string, string> data { get; }

        public KeyBlock(string name)
        {
            this.name = name;
            this.data = new Dictionary<string, string>();
        }

        public void AddValue(string key, string value)
        {
            data.Add(key, value);
        }

        public void ParseGPTResponse(string response)
        {
            this.data.Clear();

            string[] lines = response.Split("\n");
            foreach (var line in lines)
            {
                string[] parts = line.Split("=");
                if (parts.Length == 2)
                {
                    string key = parts[0].Trim();
                    string value = parts[1].Trim();
                    data.Add(key, value);
                }
            }
        }   

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            foreach (var kvp in data)
            {
                sb.AppendLine($"{kvp.Key} = {kvp.Value}");
            }
            return sb.ToString();
        }
    }
}
