CREATE TABLE IF NOT EXISTS users(
                            _login varchar (255) primary key,
                            _password varchar (255) not null                            
                            );
							
							
CREATE TABLE IF NOT EXISTS genres(
                            _genre varchar (255) primary key                           
                            );
							
							
CREATE TABLE IF NOT EXISTS users_genres(
							_login varchar (255) not null,
							_genre varchar (255) not null,
                            constraint lc foreign key(_login) references users(_login),
                            constraint gc foreign key(_genre) references genres(_genre),
							primary key (_login, _genre)
                            );
							
							
CREATE TABLE IF NOT EXISTS artists(	
	_artist_name varchar(255) primary key
)


CREATE TABLE IF NOT EXISTS song_titles(
	_song_title varchar(255) primary key
)


CREATE TABLE IF NOT EXISTS songs(
	_login varchar(255) not null,
	_artist_name varchar(255) not null,
	_song_title varchar(255) not null,
	constraint lc foreign key(_login) references users(_login),
	constraint aic foreign key(_artist_name) references artists(_artist_name),
	constraint stc foreign key(_song_title) references song_titles(_song_title),
	primary key(_login, _artist_name, _song_title)
)


CREATE TABLE IF NOT EXISTS song_genres(
	_artist_name varchar(255) not null,
	_song_title varchar(255) not null,
	_genre varchar(255) not null,
	constraint aic foreign key(_artist_name) references artists(_artist_name),
	constraint stc foreign key(_song_title) references song_titles(_song_title),
	constraint gc foreign key(_genre) references genres(_genre),
	primary key(_artist_name, _song_title, _genre)
)


CREATE TABLE IF NOT EXISTS user_playlist(
	_user varchar(255) not null,
	_playlist_name varchar(255) not null,
	_artist_name varchar(255) not null,
	_song_title varchar(255) not null,
	constraint uc foreign key(_user) references users(_login),
	constraint aic foreign key(_artist_name) references artists(_artist_name),
	constraint stc foreign key(_song_title) references song_titles(_song_title),
	primary key(_user, _playlist_name, _artist_name, _song_title)
)


CREATE TABLE IF NOT EXISTS favorite_songs(
	_login varchar(255) not null,
	_artist_name varchar(255) not null,
	_song_title varchar(255) not null,
	constraint uc foreign key(_login) references users(_login),
	constraint ac foreign key(_artist_name) references artists(_artist_name),
	constraint stc foreign key(_song_title) references song_titles(_song_title),
	primary key(_login, _artist_name, _song_title)
)


create or replace function check_password(login varchar, pwd varchar)
returns int
language plpgsql
as
$$
begin
	if ((select count(1) from users where _login = login and _password = pwd) = 1) then
		return 1;
	else
		return 0;
	end if;
end;
$$


create or replace procedure add_song(login varchar, pwd varchar, artist_name varchar, song_title varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	if ((select count(1) from artists where _artist_name = artist_name) != 1) then
		insert into artists values(artist_name);
	end if;
	if ((select count(1) from song_titles where _song_title = song_title) != 1) then
		insert into song_titles values(song_title);
	end if;
	insert into songs values(login, artist_name, song_title) on conflict do nothing;
end;
$$


create or replace function get_songs(login varchar, pwd varchar)
returns table(
	art_name varchar(255),
	sng_title varchar(255)
)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	return query
	select _artist_name, _song_title from songs where _login = login;
end;
$$


create or replace procedure add_favorite_genre(login varchar, pwd varchar, genre varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	insert into genres values(genre) on conflict do nothing;
	insert into users_genres values(login, genre) on conflict do nothing;
end;
$$


create or replace function get_genres(login varchar, pwd varchar)
returns table(
	genres varchar(255)
)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	return query
	select _genre from users_genres where _login = login;
end;
$$


create or replace procedure add_song_to_playlist(login varchar, pwd varchar, playlist_name varchar, artist_name varchar, song_title varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	if ((select count(1) from songs where _artist_name = artist_name and _song_title = song_title and _login = login) != 1) then
		raise notice 'You do not have this song: % in your list.', song_title
					  using hint = 'Add this song in your list then try to create a playlist again';
	  	return;
	end if;
	insert into user_playlist values(login, playlist_name, artist_name, song_title) on conflict do nothing;
end;
$$


create or replace function get_songs_from_playlist(login varchar, pwd varchar, playlist_name varchar)
returns table(
	plst_name varchar(255),
	art_name varchar(255),
	sng varchar(255)
)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	return query
	select _playlist_name, _artist_name, _song_title from user_playlist where _user = login and _playlist_name = playlist_name;
end;
$$


create or replace procedure change_playlist_name(login varchar, pwd varchar, playlist_name varchar, new_playlist_name varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	if ((select count(1) from user_playlist where _user = login and _playlist_name = playlist_name) = 0) then
		raise notice 'You do not have this playlist %.', playlist_name					  
	  	return;
	end if;
	update user_playlist set _playlist_name = new_playlist_name where _user = login;
end;
$$


create or replace procedure add_song_to_favorites(login varchar, pwd varchar, artist_name varchar, song_title varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	if ((select count(1) from songs where _artist_name = artist_name and _song_title = song_title and _login = login) != 1) then
		raise notice 'You do not have this song: % in your list.', song_title
					  using hint = 'Add this song in your list then try to create a playlist again';
	  	return;
	end if;
	insert into favorite_songs values(login, artist_name, song_title) on conflict do nothing;
end;
$$


create or replace function get_favorite_songs(login varchar, pwd varchar)
returns table(	
	art_name varchar(255),
	sng varchar(255)
)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	return query
	select _artist_name, _song_title from favorite_songs where _login = login;
end;
$$


create or replace procedure delete_playlist(login varchar, pwd varchar, playlist_name varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;	
	delete from user_playlist where _user = login and playlist_name = playlist_name;		
end;
$$


create or replace procedure delete_favorite_song(login varchar, pwd varchar, artist_name varchar, song_title varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;	
	delete from favorite_songs where _login = login and _artist_name = artist_name and _song_title = song_title;		
end;
$$


create or replace procedure delete_song(login varchar, pwd varchar, artist_name varchar, song_title varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;	
	delete from favorite_songs where _login = login and _artist_name = artist_name and _song_title = song_title;
	delete from songs where _login = login and _artist_name = artist_name and _song_title = song_title;		
end;
$$


create or replace procedure delete_favorite_genre(login varchar, pwd varchar, genre varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;	
	delete from users_genres where _login = login and _genre = genre;
end;
$$


create or replace procedure delete_account(login varchar, pwd varchar)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	delete from user_playlist where _user = login;
	delete from users_genres where _login = login;
	delete from favorite_songs where _login = login;
	delete from songs where _login = login;
	delete from users where _login = login;
end;
$$


create or replace function is_song_in_user_list(login varchar, pwd varchar, artist_name)
returns table(	
	art_name varchar(255),
	sng varchar(255)
)
language plpgsql
as
$$
begin
	if (check_password(login, pwd) != 1) then
		raise notice 'The user % does not exist in system or the password is incorrect.', login
		using hint = 'Please verify your data';
		return;
	end if;
	return query
	select _artist_name, _song_title from favorite_songs where _login = login;
end;
$$








