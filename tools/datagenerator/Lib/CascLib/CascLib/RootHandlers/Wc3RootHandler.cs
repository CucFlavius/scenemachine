﻿using System;
using System.Collections.Generic;
using System.IO;

namespace CASCLib
{
    public class Wc3RootHandler : RootHandlerBase
    {
        private readonly Dictionary<ulong, RootEntry> RootData = new Dictionary<ulong, RootEntry>();

        public override int Count => RootData.Count;

        public Wc3RootHandler(BinaryReader stream, BackgroundWorkerEx worker)
        {
            worker?.ReportProgress(0, "Loading \"root\"...");

            using (StreamReader sr = new StreamReader(stream.BaseStream))
            {
                string line;

                while ((line = sr.ReadLine()) != null)
                {
                    string[] tokens = line.Split('|');

                    if (tokens.Length != 3 && tokens.Length != 4)
                        throw new InvalidDataException("tokens.Length != 3 && tokens.Length != 4");

                    string file;

                    if (tokens[0].IndexOf(':') != -1)
                    {
                        string[] tokens2 = tokens[0].Split(':');

                        if (tokens2.Length == 2 || tokens2.Length == 3 || tokens2.Length == 4)
                            file = Path.Combine(tokens2);
                        else
                            throw new InvalidDataException("tokens2.Length");
                    }
                    else
                    {
                        file = tokens[0];
                    }

                    if (!Enum.TryParse(tokens[2], out LocaleFlags locale))
                    {
                        locale = LocaleFlags.All;
                    }

                    ulong fileHash = Hasher.ComputeHash(file);

                    RootData[fileHash] = new RootEntry()
                    {
                        LocaleFlags = locale,
                        ContentFlags = ContentFlags.None,
                        cKey = tokens[1].FromHexString().ToMD5()
                    };

                    CASCFile.Files[fileHash] = new CASCFile(fileHash, file);
                }
            }

            worker?.ReportProgress(100);
        }

        public override IEnumerable<KeyValuePair<ulong, RootEntry>> GetAllEntries()
        {
            return RootData;
        }

        public override IEnumerable<RootEntry> GetAllEntries(ulong hash)
        {
            if (RootData.TryGetValue(hash, out RootEntry rootEntry))
                yield return rootEntry;
        }

        // Returns only entries that match current locale and content flags
        public override IEnumerable<RootEntry> GetEntries(ulong hash)
        {
            return GetEntriesForSelectedLocale(hash);
        }

        public override void LoadListFile(string path, BackgroundWorkerEx worker = null)
        {

        }

        protected override CASCFolder CreateStorageTree()
        {
            var root = new CASCFolder("root");

            CountSelect = 0;

            foreach (var entry in RootData)
            {
                if ((entry.Value.LocaleFlags & Locale) == 0)
                    continue;

                CreateSubTree(root, entry.Key, CASCFile.Files[entry.Key].FullName);
                CountSelect++;
            }

            // Cleanup fake names for unknown files
            CountUnknown = 0;

            Logger.WriteLine("WC3RootHandler: {0} file names missing for locale {1}", CountUnknown, Locale);

            return root;
        }

        public override void Clear()
        {
            Root.Files.Clear();
            Root.Folders.Clear();
            CASCFile.Files.Clear();
        }

        public override void Dump(EncodingHandler encodingHandler = null)
        {

        }
    }
}
