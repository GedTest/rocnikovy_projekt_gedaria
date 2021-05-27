extends Node

var languages = {
	"čeština":{
		"throwing":"Za pomocí kamenů nyní můžeš házet na včelí úly, tím vyprovokuješ včely. [color=#004a23]Zmáčkni tlačítko 'Q'[/color] a zamiř na úl, potom stiskni levé tlačítko myši",
		"raking_out_leaves_horizontal":"Vladimír může svými hráběmi vodorovně odhrnovat listí. [color=#004a23]Podrž tlačítko 'Shift'[/color]",
		"raking_out_leaves_vertical":"Vladimír může hráběmi ničit svislé barikády z listí. [color=#004a23]Zmáčkni levé tlačítko myši.[/color]",
		"hiding":"V křoví je Vladimír skryt zrakům jeho nepřátel. [color=#004a23]Zmáčkni 'S'[/color] pro schování se do keře",
		"heavy_attack":"Štíty je možno prolomit silným útokem. Silný útok působí protivníkům dvojnásobné poškození, ale je omezený nabitím unikátními listy, které jsou schované v úrovni. [color=#004a23]Zmáčkni pravé tlačítko myši.[/color]",
		"attack":"Pro útok [color=#004a23]zmáčkni levé tlačítko myši[/color]",
		"interaction":"[color=#004a23]Zmáčkni 'E'[/color] pro interakci",
		"movement":"Pro pohyb použij [color=#004a23]tlačítka 'A' / 'D'[/color]",
		"blocking":"[color=#004a23]Podržením 'Mezerníku'[/color] ve správný čas zablokuješ nepřítelův útok",
		"shooting":"Nyní můžeš střílet kameny prakem na nepřátele, čímž jim způsobíš poškození.",
		"raking":"Vladimír může svými hráběmi hrabat listí na hromady. S něktrými je pak možno i hýbat. [color=#004a23]Zmáčkni a drž 'Shift' + 'A'/'D'[/color]",
		"wind":"Pomocí [color=#004a23]větru[/color] může Vladimír dostat listy na vyvýšená místa.",
		"jumping":"Pro skok [color=#004a23]zmáčkni 'W'[/color]",
		"crawling":"Pro skrčení se [color=#004a23]zmáčkni 'S'[/color]",
		"boss_warden_quote":"„Rozluč se svou rodinou spratku, vidíš je naposled!“",
		"letter":"„Našli jste již ty hrábě, pro které jsem vás vyslal? Musíme je urychleně najít, za každou cenu. Potřebuji víc duší, pro můj magický experiment -  „metamorfózu“, přiveďte co nejvíce vesničanů, pokračujte v pátrání po mocné duši. Nadešel čas odvést Vladimírova otce. Dostavte se do mé pevnosti, ihned jakmile jej zadržíte. Podejte hlášení kapitánu _____.“",
		"start":"Začít hrát",
		"load":"Nahrát hru",
		"options":"Nastavení",
		"achievements":"Úspěchy",
		"credits":"Autoři",
		"quit":"Ukončit hru",
		"bush_quest":"Ahoj, oni.... ukradli mi mé děti.... přineseš je zpátky, že mládenče?",
		"bush_thanks":"Oh děkuji mladíku!",
		"pause":"Stisknutím [color=#004a23]tlačítka 'Esc'[/color] hru zastavíš a zobrazí se nabídka menu.",
	},
	"english":{
		"throwing":"With the help of pebbles, you can throw at beehives, thus provoking bees. [color=#004a23]Press the 'Q' button[/color] and aim at the hive, then press left mouse button",
		"raking_out_leaves_horizontal":"Vladimir can break the leaf barrier with his rake. [color=#004a23]Hold down the 'Shift' key[/color]",
		"raking_out_leaves_vertical":"With his rakes, Vladimir can destroy vertical barricades made of leaves. [color=#004a23]Press the left mouse button.[/color]",
		"hiding":"In the bushes, Vladimir is hidden from the sight of his enemies. [color=#004a23]Press 'S'[/color] to hide in the bush",
		"heavy_attack":"Shields can be broken by a heavy attack. A heavy attack deals double damage to enemies, but is limited by recharging unique leaves that are hidden in the level. [color=#004a23]Press right mouse button[/color].",
		"attack":"[color=#004a23]Press the left mouse button[/color] to attack",
		"interaction":"[color=#004a23]Press 'E'[/color] to interact",
		"movement":"[color=#004a23]Use 'A' / 'D' buttons[/color] to move",
		"blocking":"[color=#004a23]Hold down the 'Spacebar'[/color] at the right time to        block the enemy's attack",
		"shooting":"Now you can shoot pebbles at enemies and inflict damage    on them.",
		"raking":"Vladimir can rake leaves into piles with his rakes. It is then possible to move with some of them. [color=#004a23]Hold 'Shift' + 'A'/'D'[/color]",
		"wind":"With the help  of  the [color=#004a23]wind[/color], Vladimir can get the leaves to elevated places.",
		"jumping":"[color=#004a23]Press 'W'[/color] to jump",
		"crawling":"[color=#004a23]Press 'S'[/color] to crouch",
		"boss_warden_quote":"„Say goodbye to your family, brat. You see them for the last time!“",
		"letter":"„Have you already found the rakes for which I sent you? We must find them quickly, at all costs. I need more souls, for my magical experiment - „metamorphosis“, bring as many villagers as possible, continue to search for a powerful soul. It's time to take Vladimir's father away. Come to my fortress as soon as you get him. Report to Captain _____.“",
		"start":"Start Game",
		"load":"Load Game",
		"options":"Settings",
		"achievements":"Achievements",
		"credits":"Authors",
		"quit":"Quit",
		"bush_quest":"Hi, they .... stole my children .... will you bring them back, young man? ",
		"bush_thanks":"Oh thank you young man!",
		"pause":"[color=#004a23]Press the 'Esc'[/color] button to stop the game and display the menu.",
	},
	"polskie": {
		"start":"Zacząć gre",
		"load":"Wczytaj grę",
		"options":"Ustawienia",
		"achievements":"Osiągnięcia",
		"credits":"Autorski",
		"quit":"Zakończyć grę",
	},
	"deutsche":{
		"start":"Spiel beginnen",
		"load":"Spiel laden",
		"options":"Einstellungen",
		"achievements":"Erfolge",
		"credits":"Autoren",
		"quit":"Spiel verlassen",
	},
	"slovenčina":{
		"start":"Začať hru",
		"load":"Načítať  hru",
		"options":"Nastavenie",
		"achievements":"Úspechy",
		"credits":"Autori",
		"quit":"Ukončiť hru",
	},
	"français":{
		"start":"Commencer le jeu",
		"load":"Charger le jeu",
		"options":"Réglages",
		"achievements":"Réalisations",
		"credits":"Auteurs",
		"quit":"Quitter le jeu",
	},
	"italiano":{
		"start":"Inizia il gioco",
		"load":"Caricare il gioco",
		"options":"Impostazioni",
		"achievements":"Realizzazioni",
		"credits":"Autori",
		"quit":"Abbandonare il gioco",
	},
	"русский":{
		"start":"Начать игру",
		"load":"Загрузите игру",
		"options":"Настройки",
		"achievements":"Достижения",
		"credits":"Авторы",
		"quit":"Выйти из игры",
	},
	"español":{
		"start":"Empieza el juego",
		"load":"Cargar juego",
		"options":"Configuraciones",
		"achievements":"Logros",
		"credits":"Autores",
		"quit":"Salir del juego",
	},
	"português":{
		"start":"Comece o jogo",
		"load":"Carregar jogo",
		"options":"Configurações",
		"achievements":"conquistas",
		"credits":"Autores",
		"quit":"Desistir do jogo",
	}
}

func translate(texts, other_language):
	for key in texts.keys():
		texts[key].text = languages[other_language][key]
		
		if "bbcode_text" in texts[key]:
			texts[key].bbcode_text = "[center]"+languages[other_language][key]
