
cfg = cfg or {}

cfg.game = {
	width = 480,
	height = 320,
}

cfg.role = {

	hero = { plist = "Boy.plist", img = "Boy.pvr.ccz", life = 100,
		attacka_damage = 30, attackb_damage = 30, attackc_damage = 30,
		runattack_damage = 80, runattack_consume = 10,
		animation = {

			idle = {"boy_idle_%02d.png", 0, 2, 1/5},
			run = {"boy_run_%02d.png", 0, 7, 1/12},

			attacka1 = {"boy_attack_00_%02d.png", 0, 3, 1/10},
			attacka2 = {"boy_attack_00_%02d.png", 4, 7, 1/15},

			attackb1 = {"boy_attack_01_%02d.png", 0, 3, 1/10},
			attackb2 = {"boy_attack_01_%02d.png", 4, 7, 1/15},

			attackc1 = {"boy_attack_02_%02d.png", 0, 2, 1/10},
			attackc2 = {"boy_attack_02_%02d.png", 3, 5, 1/12},

			charge = {"boy_change_attack_%02d.png", 0, 3, 1/5},

			chargeattack1 = {"boy_change_attack_%02d.png", 4, 6, 1/4},
			chargeattack2 = {"boy_change_attack_%02d.png", 7, 10, 1/5},

			runattack1 = {"boy_run_attack_%02d.png", 0, 2, 1/30},
			runattack2 = {"boy_run_attack_%02d.png", 3, 3, 1/6},
			runattack3 = {"boy_run_attack_%02d.png", 4, 4, 1/6},
			runattack4 = {"boy_run_attack_%02d.png", 5, 5, 1/6},
			runattack5 = {"boy_run_attack_%02d.png", 6, 6, 1/6},


			hurt = {"boy_hurt_%02d.png", 0, 1, 1/6},

			dead = {"boy_dead_%02d.png", 0, 2, 1/6}
			},
		},

	enemy = { plist = "enemy.plist", img = "enemy.pvr.ccz", life = 100,
		attack_damage = 5,
		animation = {
			idle = {"bear_idle_%02d.png", 0, 2, 1/6},
			run = {"bear_run_%02d.png", 0, 3, 1/8},
			attack1 = {"bear_attack_00_%02d.png", 0, 3, 1/8},
			attack2 = {"bear_attack_00_%02d.png", 4, 7, 1/8},
			hurt = {"bear_hurt_%02d.png", 0, 1, 1/4},
			dead = {"bear_dead_%02d.png", 0, 1, 1/4},
	}},
}