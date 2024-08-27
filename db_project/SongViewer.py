import psycopg2
from lyrics_extractor import SongLyrics


class SongViewer:

    def __init__(self, host: str, database: str, user: str, password: str):
        self.song_lyrics = SongLyrics('example', 'example')
        try:
            self.connection = psycopg2.connect(host=host, database=database, user=user, password=password)
            self.cursor = self.connection.cursor()

            self.cursor.execute("CREATE TABLE IF NOT EXISTS users("
                                "_login varchar (255) primary key,"
                                "_password varchar (255) not null"                            
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS genres("
                                "_genre varchar (255) primary key"                           
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS users_genres("
                                "_login varchar (255) not null,"
                                "_genre varchar (255) not null,"
                                "constraint lc foreign key(_login) references users(_login),"
                                "constraint gc foreign key(_genre) references genres(_genre),"
                                "primary key (_login, _genre)"
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS artists("                                
                                "_artist_name varchar(255) primary key"
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS song_titles("
                                "_song_title varchar(255) primary key"
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS songs("
                                "_login varchar(255) not null,"
                                "_artist_name varchar(255) not null,"                                
                                "_song_title varchar(255) not null,"
                                "constraint lc foreign key(_login) references users(_login),"
                                "constraint aic foreign key(_artist_name) references artists(_artist_name),"
                                "constraint stc foreign key(_song_title) references song_titles(_song_title),"
                                "primary key(_login, _artist_name, _song_title)"
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS song_genres("
                                "_artist_name varchar(255) not null,"
                                "_song_title varchar(255) not null,"
                                "_genre varchar(255) not null,"
                                "constraint aic foreign key(_artist_name) references artists(_artist_name),"
                                "constraint stc foreign key(_song_title) references song_titles(_song_title),"
                                "constraint gc foreign key(_genre) references genres(_genre),"
                                "primary key(_artist_name, _song_title, _genre)"
                                ")")

            self.cursor.execute("CREATE TABLE IF NOT EXISTS user_playlist("
                                "_user varchar(255) not null,"
                                "_playlist_name varchar(255) not null,"
                                "_artist_name varchar(255) not null,"
                                "_song_title varchar(255) not null,"
                                "constraint uc foreign key(_user) references users(_login),"
                                "constraint aic foreign key(_artist_name) references artists(_artist_name),"
                                "constraint stc foreign key(_song_title) references song_titles(_song_title),"
                                "primary key(_user, _playlist_name, _artist_name, _song_title)"
                                ")")

            self.connection.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def add_user(self, login, password):
        try:
            self.cursor.execute("""INSERT INTO users(_login, _password) VALUES(%s, %s)
                                ON CONFLICT(_login) DO NOTHING""",
                                (login, password))
            self.connection.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def add_song(self, login, password, artist_name, song_title):
        try:
            self.cursor.execute("""CALL add_song(%s, %s, %s, %s)""", (login, password, artist_name, song_title))
            self.connection.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def get_songs(self, login, password):
        try:
            self.cursor.execute("""SELECT * FROM get_songs(%s, %s)""", (login, password))
            return self.cursor.fetchall()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def add_genre(self, login, password, genre):
        try:
            self.cursor.execute("""CALL add_genre(%s, %s, %s)""", (login, password, genre))
            self.connection.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def get_genres(self, login, password):
        try:
            self.cursor.execute("""SELECT * FROM get_genres(%, %)""", (login, password))
            return self.cursor.fetchall()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def add_song_to_playlist(self, login, password, playlist_name, artist_name, song_title):
        try:
            self.cursor.execute("""CALL add_song_to_playlist(%s, %s, %s, %s, %s)""",
                                (login, password, playlist_name, artist_name, song_title))
            self.connection.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def get_songs_from_playlist(self, login, password, playlist_name):
        try:
            self.cursor.execute("""SELECT * FROM get_songs_from_playlist(%s, %s, %s)""",
                                (login, password, playlist_name))
            return self.cursor.fetchall()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def change_playlist_name(self, login, password, playlist_name, new_playlist_name):
        try:
            self.cursor.execute(""""CALL change_playlist_name(%s, %s, %s, %s)""",
                                (login, password, playlist_name, new_playlist_name))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def add_song_to_favorites(self, login, password, artist_name, song_title):
        try:
            self.cursor.execute(""""CALL add_song_to_favorites(%s, %s, %s, %s)""",
                                (login, password, artist_name, song_title))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def get_favorite_songs(self, login, password):
        try:
            self.cursor.execute(""""SELECT * FROM get_favorite_songs(%s, %s)""",
                                (login, password))
            return self.cursor.fetchall()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def delete_playlist(self, login, password, playlist_name):
        try:
            self.cursor.execute(""""CALL delete_playlist(%s, %s, %s)""",
                                (login, password, playlist_name))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def delete_favorite_song(self, login, password, artist_name, song_title):
        try:
            self.cursor.execute(""""CALL delete_favorite_song(%s, %s, %s, %s)""",
                                (login, password, artist_name, song_title))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def delete_song(self, login, password, artist_name, song_title):
        try:
            self.cursor.execute(""""CALL delete_song(%s, %s, %s, %s)""",
                                (login, password, artist_name, song_title))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def delete_favorite_genre(self, login, password, genre):
        try:
            self.cursor.execute(""""CALL delete_favorite_genre(%s, %s, %s)""",
                                (login, password, genre))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def delete_account(self, login, password):
        try:
            self.cursor.execute(""""CALL delete_account(%s, %s)""",
                                (login, password))
            self.cursor.commit()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def get_lyrics(self, login, pwd, artist_name, song_name):
        try:
            self.cursor.execute("""SELECT * FROM is_song_in_user_list(%s, %s, %s, %s)""",
                                (login, pwd, artist_name, song_name))
            is_song_in_user_list = self.cursor.fetchone()
            if is_song_in_user_list:
                try:
                    lyrics = self.song_lyrics.get_lyrics(song_name)['lyrics']
                    return lyrics
                except ValueError:
                    print("Check the song and artist names")
                    raise ValueError
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error

    def __del__(self):
        try:
            self.cursor.close()
            self.connection.close()
        except psycopg2.OperationalError as error:
            print("Error type:", type(error))
            raise error


ab = SongViewer('localhost', 'db_project', 'postgres', 'password')
# ab.add_song('Bair', '123', 'Хаски', 'Бог войны')
# ab.get_lyrics('Bair', '123', 'Хаски', 'Бит ш')
# ab.add_song_to_playlist('Bair', '123', 'Yeahy', 'Nirvana', 'Lithium')
print(ab.get_songs_from_playlist('Bair', '123','Yeahy'))

