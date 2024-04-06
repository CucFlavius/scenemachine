﻿using DBFileReaderLib.Common;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.CompilerServices;
using System.Text;

namespace DBFileReaderLib.Readers
{
    class HTFXRow : IDBRow, IHotfixEntry, IEquatable<HTFXRow>
    {
        private BitReader m_data;
        private readonly IHotfixEntry m_hotfixEntry;

        public int Id { get; set; }
        public BitReader Data { get => m_data; set => m_data = value; }

        public int PushId => m_hotfixEntry.PushId;
        public uint TableHash => m_hotfixEntry.TableHash;
        public int RecordId => m_hotfixEntry.RecordId;
        public bool IsValid => m_hotfixEntry.IsValid;
        public int DataSize => m_hotfixEntry.DataSize;

        public HTFXRow(BitReader data, IHotfixEntry hotfixEntry)
        {
            m_data = data;
            m_hotfixEntry = hotfixEntry;

            Id = hotfixEntry.RecordId;
        }

        private static Dictionary<Type, Func<BitReader, object>> simpleReaders = new Dictionary<Type, Func<BitReader, object>>
        {
            [typeof(ulong)] = (data) => GetFieldValue<ulong>(data),
            [typeof(long)] = (data) => GetFieldValue<long>(data),
            [typeof(float)] = (data) => GetFieldValue<float>(data),
            [typeof(int)] = (data) => GetFieldValue<int>(data),
            [typeof(uint)] = (data) => GetFieldValue<uint>(data),
            [typeof(short)] = (data) => GetFieldValue<short>(data),
            [typeof(ushort)] = (data) => GetFieldValue<ushort>(data),
            [typeof(sbyte)] = (data) => GetFieldValue<sbyte>(data),
            [typeof(byte)] = (data) => GetFieldValue<byte>(data),
            [typeof(string)] = (data) => data.ReadCString(),
        };

        private static Dictionary<Type, Func<BitReader, int, object>> arrayReaders = new Dictionary<Type, Func<BitReader, int, object>>
        {
            [typeof(ulong[])] = (data, cardinality) => GetFieldValueArray<ulong>(data, cardinality),
            [typeof(long[])] = (data, cardinality) => GetFieldValueArray<long>(data, cardinality),
            [typeof(float[])] = (data, cardinality) => GetFieldValueArray<float>(data, cardinality),
            [typeof(int[])] = (data, cardinality) => GetFieldValueArray<int>(data, cardinality),
            [typeof(uint[])] = (data, cardinality) => GetFieldValueArray<uint>(data, cardinality),
            [typeof(ulong[])] = (data, cardinality) => GetFieldValueArray<ulong>(data, cardinality),
            [typeof(ushort[])] = (data, cardinality) => GetFieldValueArray<ushort>(data, cardinality),
            [typeof(short[])] = (data, cardinality) => GetFieldValueArray<short>(data, cardinality),
            [typeof(byte[])] = (data, cardinality) => GetFieldValueArray<byte>(data, cardinality),
            [typeof(sbyte[])] = (data, cardinality) => GetFieldValueArray<sbyte>(data, cardinality),
            [typeof(string[])] = (data, cardinality) => Enumerable.Range(0, cardinality).Select(i => data.ReadCString()).ToArray(),
        };

        public void GetFields<T>(FieldCache<T>[] fields, T entry)
        {
            Data.Position = 0;

            for (int i = 0; i < fields.Length; i++)
            {
                FieldCache<T> info = fields[i];
                if (info.IndexMapField)
                {
                    info.Setter(entry, Convert.ChangeType(Id, info.FieldType));
                    continue;
                }

                object value = null;

                if (info.IsArray)
                {
                    if (arrayReaders.TryGetValue(info.MetaDataFieldType, out var reader))
                        value = reader(m_data, info.Cardinality);
                    else
                        throw new Exception("Unhandled array type: " + typeof(T).Name);
                }
                else
                {
                    if (simpleReaders.TryGetValue(info.MetaDataFieldType, out var reader))
                        value = reader(m_data);
                    else
                        throw new Exception("Unhandled field type: " + typeof(T).Name);
                }

                if (info.IsNonInlineRelation)
                {
                    var casted = Convert.ChangeType(value, info.FieldType);
                    info.Setter(entry, casted);
                }
                else
                {
                    info.Setter(entry, value);
                }
            }
        }

        private static T GetFieldValue<T>(BitReader r) where T : struct
        {
            return r.ReadValue64(Unsafe.SizeOf<T>() * 8).GetValue<T>();
        }

        private static T[] GetFieldValueArray<T>(BitReader r, int cardinality) where T : struct
        {
            T[] array = new T[cardinality];
            for (int i = 0; i < array.Length; i++)
                array[i] = r.ReadValue64(Unsafe.SizeOf<T>() * 8).GetValue<T>();

            return array;
        }


        #region Interface Methods

        public IDBRow Clone()
        {
            return (IDBRow)MemberwiseClone();
        }
        
        public override int GetHashCode()
        {
            unchecked
            {
                int hash = 17;
                hash = (hash * 486187739) + PushId;
                hash = (hash * 486187739) + TableHash.GetHashCode();
                hash = (hash * 486187739) + RecordId;
                hash = (hash * 486187739) + (IsValid ? 1 : 0);
                hash = (hash * 486187739) + DataSize;
                hash = (hash * 486187739) + m_data.GetHashCode();
                return hash;
            }
        }

        public bool Equals(HTFXRow other)
        {
            return PushId == other.PushId &&
                   TableHash == other.TableHash &&
                   RecordId == other.RecordId &&
                   IsValid == other.IsValid &&
                   DataSize == other.DataSize;
        }

        #endregion
    }

    class HTFXReader : BaseReader
    {
        public readonly int Version;
        public readonly int BuildId;

        private const int HeaderSize = 12;
        private const int ExtendedHeaderSize = 44;
        private const uint HTFXFmtSig = 0x48544658; // XFTH

        public HTFXReader(string dbcFile) : this(new FileStream(dbcFile, FileMode.Open)) { }

        public HTFXReader(Stream stream)
        {
            using (var reader = new BinaryReader(stream, Encoding.UTF8))
            {
                if (reader.BaseStream.Length < HeaderSize)
                    throw new InvalidDataException("Hotfix file is corrupted!");

                uint magic = reader.ReadUInt32();
                if (magic != HTFXFmtSig)
                    throw new InvalidDataException("Hotfix file is corrupted!");

                Version = reader.ReadInt32();
                BuildId = reader.ReadInt32();

                // Extended header
                if (Version >= 5)
                {
                    if (reader.BaseStream.Length < ExtendedHeaderSize)
                        throw new InvalidDataException("Hotfix file is corrupted!");

                    reader.BaseStream.Position += 32; // sha hash
                }

                long length = reader.BaseStream.Length;

                // Version 8 was first seen in 9.1.0.39291 with no actual format changes, likely by error. A new field was added later in build 2.5.2.39570.
                // This means we have to 'detect' which of the formats this actually is...
                // NOTE: This method will fail on files that don't have at least 2 hotfix entries in them.
                if (Version == 8 && length > (reader.BaseStream.Position + 24))
                {
                    // Save position to go back to later
                    var prePos = reader.BaseStream.Position;

                    if (reader.ReadUInt32() != HTFXFmtSig)
                        throw new Exception("Invalid hotfix entry magic!");

                    reader.BaseStream.Position += 16; // Skip ahead by 16 bytes, this includes the 4 bytes _actually_ added in V8

                    var dataSize = reader.ReadInt32();

                    if(reader.BaseStream.Length > reader.BaseStream.Position + 4 + dataSize)
                        reader.BaseStream.Position += 4 + dataSize; // Skip ahead by 4 bytes + size of hotfix data

                    // Check if we encounter a hotfix signature in the next hotfix record (if exists)
                    if(reader.BaseStream.Length > reader.BaseStream.Position + 4)
                    {
                        if (reader.ReadUInt32() != HTFXFmtSig)
                        {
                            // Fall back to version 7 reading if we don't encounter HTFX magic
                            Version = 7;
                        }
                    }
                        
                    // Go back to pre-detection position
                    reader.BaseStream.Position = prePos;
                }

                var readerFunc = GetReaderFunc();

                while (reader.BaseStream.Position < length)
                {
                    magic = reader.ReadUInt32();
                    if (magic != HTFXFmtSig)
                        throw new InvalidDataException("Hotfix file is corrupted!");

                    IHotfixEntry hotfixEntry = readerFunc.Invoke(reader);
                    BitReader bitReader = new BitReader(reader.ReadBytes(hotfixEntry.DataSize));
                    HTFXRow rec = new HTFXRow(bitReader, hotfixEntry);

                    _Records.Add(_Records.Count, rec);
                }
            }
        }


        public IEnumerable<HTFXRow> GetRecords(uint tablehash)
        {
            foreach (HTFXRow record in _Records.Values)
                if (record.TableHash == tablehash)
                    yield return record;
        }

        public void Combine(HTFXReader reader)
        {
            var lookup = new HashSet<HTFXRow>(_Records.Values.Cast<HTFXRow>());

            // copy records not in the current set
            foreach (HTFXRow row in reader._Records.Values)
            {
                if (!lookup.Contains(row))
                {
                    _Records.Add(_Records.Count, row);
                    lookup.Add(row);
                }
            }
        }


        private Func<BinaryReader, IHotfixEntry> GetReaderFunc()
        {
            Type hotfixType;

            if (Version == 1)
                hotfixType = typeof(HotfixEntryV1);
            else if (Version >= 2 && Version <= 6)
                hotfixType = typeof(HotfixEntryV2);
            else if (Version == 7) 
                hotfixType = typeof(HotfixEntryV7);
            else if (Version == 8)
                hotfixType = typeof(HotfixEntryV8);
            else if (Version == 9)
                hotfixType = typeof(HotfixEntryV9);
            else
                throw new NotSupportedException($"Hotfix version {Version} is not supported");

            var param = Expression.Parameter(typeof(BinaryReader), "reader");
            var readMethod = typeof(Extensions).GetMethod("Read").MakeGenericMethod(hotfixType);
            var callExpression = Expression.Call(readMethod, param);
            var convertExpression = Expression.Convert(callExpression, typeof(IHotfixEntry));

            return Expression.Lambda<Func<BinaryReader, IHotfixEntry>>(convertExpression, param).Compile();
        }
    }
}
