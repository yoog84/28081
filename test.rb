#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db #inicializiruem globaln peremen
	@db = SQLite3::Database.new 'leprosorium.db' # v module sqlite suchestvuet class Database, v kotorom est metod .new,kotory prinimaet parametr leprosorium.db
	@db.results_as_hash = true #rezultaty vozvrashayoutsya v vide hash ,a ne v vide massiva(udobnee k nim obrashatsya)(stroka neobyazatelna)
end

#before vizivaetsya kagdy raz pri perezagruzke lyouboy stranicy
before do
	init_db
end

#sozdanie tablicy v BD dlya postov
configure do #metod configuracii vizivaetsya kagdy raz pri inicializacii prilogeniya(pri izmenenii file(kod programmy) ili,& obnovlenii stranicy)
	init_db
	#vstavlyaem kod sozdanoy v programme sqlite3, obyazatelno vstavlyaem 'IF NOT EXISTS' dlya togo,chtoby tabl ne peresozdavalas zanovo
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(  
    	id INTEGER PRIMARY KEY AUTOINCREMENT,
    	created_date DATE,
   		content TEXT
   	)'

get '/' do
	#vivod spiska postov na ekran iz bd #select * from Posts (order by id desc) - kod izsqlite3 (vivodit dannie iz bd naoborot)
	@results = @db.execute 'select * from Posts order by id desc' 
	erb :index
end

#obrabotchik get zaprosa /new(brauzer poluchaet stranicu s servera)
get '/new' do
  erb :new #podgrugaem file new.erb
end

post '/new' do #obrabotchik post zaprosa /new(brauzer otpravlyaet dannie na server)
	content = params[:content] #poluchaem peremennuyou iz post zaprosa

	#proverka parametrov (vvel li chto to polzovatel v okno komenta)
	if content.length <= 0
		@error = 'Vvedite text v post'
		return erb :new
	end

	#sohranenie dannih v BD #kod iz sqlite,kotory vstavlyaet text posta & datu(data avtomatom)
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	#perenapravlenie na glavnuyou stranicu
	redirect to '/'
end

#vozvrashaem predstavlenie(view) details.erb
	erb :details
end

#obrabotchik post zaprosa /details/...(brauzer otpravlaet dannie na server)
post '/details/:post_id' do
	#poluchaem peremennuyou iz url
	post_id = params[:post_id]

	#poluchaem peremennuyou iz post zaprosa
	content = params[:content]

	# sohranenie dannih v BD #kod iz sqlite,kotory vstavlyaet text komenta k postu & datu(data avtomatom)
	@db.execute 'insert into Comments
		(
			content, 
			created_date,
			post_id
		)
			values
		(
			?,
			datetime(),
			?
		)', [content, post_id] 

	#perenapravlenie na stranicu posta
	redirect to('/details/' + post_id)
end