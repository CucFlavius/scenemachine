using OpenAI.Chat;
using OpenAI.Models;
using OpenAI;

namespace LocalizationTool
{
    public class Localization
    {
        const string ADDON_LOCALIZATION_PATH = "..\\..\\..\\..\\..\\..\\scenemachine\\res\\locale\\";

        bool isSourceLocale { get; }
        string languageKey { get; }
        string languageName { get; }
        string localizationPath { get; }
        Dictionary<string, KeyBlock> keyBlocks { get; }

        public Localization(string languageKey, string languageName, bool isSourceLocale = false)
        {
            this.languageKey = languageKey;
            this.languageName = languageName;
            this.isSourceLocale = isSourceLocale;
            this.localizationPath = $"{ADDON_LOCALIZATION_PATH}{this.languageKey}.lua";
            this.keyBlocks = new Dictionary<string, KeyBlock>();
            Read();
        }

        public async Task Localize(Localization sourceLocalization)
        {
            if (isSourceLocale) { return; }
            Console.WriteLine($"Localizing: {this.languageKey} {this.languageName}");
            Console.WriteLine();

            using var api = new OpenAIClient(OpenAIAuthentication.LoadFromEnv());

            foreach (var block in sourceLocalization.keyBlocks)
            {
                Console.WriteLine($"{block.Key}");

                var data = block.Value.ToString();
                var localizedData = await GetGPTLocalizedText(api, data, this.languageKey);

                KeyBlock localizedBlock = new KeyBlock(block.Key);
                localizedBlock.ParseGPTResponse(localizedData);

                this.keyBlocks[block.Key] = localizedBlock;

                Console.WriteLine(localizedBlock.ToString());
            }   

            Write();
        }

        void Read()
        {
            if (File.Exists(this.localizationPath))
            {
                string[] lines = File.ReadAllLines(this.localizationPath);

                KeyBlock? currentBlock = null;

                for (int i = 0; i < lines.Length; i++)
                {
                    if (lines[i].StartsWith("-- "))
                    {
                        currentBlock = new KeyBlock(lines[i]);
                        keyBlocks.Add(lines[i], currentBlock);
                    }

                    if (currentBlock != null)
                    {
                        if (lines[i].StartsWith("L["))
                        {
                            string key = lines[i].Split(" = ")[0];
                            string value = lines[i].Split(" = ")[1];
                            currentBlock.AddValue(key, value);
                        }
                    }   
                }
            }
        }

        void Write()
        {
            using StreamWriter sw = new StreamWriter(this.localizationPath);
            WriteHeader(sw);

            foreach (var block in keyBlocks)
            {
                sw.WriteLine(block.Key);
                sw.WriteLine(block.Value.ToString());
            }
        }

        void WriteHeader(StreamWriter writer)
        {
            writer.WriteLine("local AceLocale = LibStub(\"AceLocale-3.0\");");
            writer.WriteLine($"local L = AceLocale:NewLocale(\"SceneMachine\", \"{this.languageKey}\", false);");
            writer.WriteLine("if not L then return end");
            writer.WriteLine();
        }

        async Task<string> GetGPTLocalizedText(OpenAIClient api, string input, string language)
        {
            var messages = new List<Message>
            {
                new Message(Role.System, "You are a helpful assistant."),
                new Message(Role.User, $"Need to localize the following to {language}: {input}"),
            };
            var chatRequest = new ChatRequest(messages, Model.GPT3_5_Turbo);
            var response = await api.ChatEndpoint.GetCompletionAsync(chatRequest);
            var choice = response.FirstChoice;

            return choice.Message;
        }
    }
}
