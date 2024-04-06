using LocalizationTool;

Dictionary<string, string> localizations = new Dictionary<string, string>()
{
    { "enUS", "English (United States)" },
    { "esMX", "Spanish (Mexico)" },
    { "ptBR", "Portuguese" },
    { "deDE", "German" },
    //{ "enGB", "English (Great Britain)" },
    { "esES", "Spanish (Spain)" },
    { "frFR", "French" },
    { "itIT", "Italian" },
    { "ruRU", "Russian" },
    { "koKR", "Korean" },
    { "zhTW", "Chinese (Traditional)" },
    { "zhCN", "Chinese (Simplified)" },
};

var sourceLocalization = new Localization("enUS", "English (United States)", true);

foreach (var kvp in localizations)
{
    if (kvp.Key == "enUS") { continue; }
    var localization = new Localization(kvp.Key, kvp.Value);
    await localization.Localize(sourceLocalization);
}