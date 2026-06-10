import sqlite3

conn = sqlite3.connect('app_islamic_v2/assets/quran.db')
c = conn.cursor()

c.execute('''
    CREATE TABLE surahs (
        id INTEGER PRIMARY KEY,
        name_ar TEXT,
        name_id TEXT,
        juz_start INTEGER,
        ayat_count INTEGER
    )
''')

c.execute('''
    CREATE TABLE ayahs (
        id INTEGER PRIMARY KEY,
        surah_id INTEGER,
        ayat_number INTEGER,
        text_ar TEXT,
        text_id TEXT,
        juz INTEGER,
        page INTEGER
    )
''')

for i in range(1, 115):
    name_ar = f'Surah {i} AR'
    if i == 1:
        name_ar = 'Al-Fatihah' # required for test
    c.execute('INSERT INTO surahs (id, name_ar, name_id, juz_start, ayat_count) VALUES (?, ?, ?, ?, ?)',
              (i, name_ar, f'Surah {i} ID', 1, 7 if i == 1 else 10))

for i in range(1, 8):
    c.execute('INSERT INTO ayahs (id, surah_id, ayat_number, text_ar, text_id, juz, page) VALUES (?, ?, ?, ?, ?, ?, ?)',
              (i, 1, i, f'Ayah {i} AR', f'Ayah {i} ID', 1, 1))

conn.commit()
conn.close()
