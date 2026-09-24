extends SceneTree

func _init() -> void:
	print("==================================================")
	print("⚔️ BẮT ĐẦU KIỂM THỬ TỰ ĐỘNG HỆ THỐNG SIN EATER ⚔️")
	print("==================================================")
	
	# 1. Setup Stats
	var p_stats = BattlerStats.new()
	p_stats.battler_name = "Hiệp Sĩ Khổ Hạnh"
	p_stats.max_vessel = 100
	p_stats.base_attack = 20
	p_stats.guilt_scaling = 1.0
	
	var b_stats = BattlerStats.new()
	b_stats.battler_name = "Kẻ Cai Ngục"
	b_stats.max_blood = 150
	b_stats.max_sin = 100
	
	var player = Battler.new()
	player.setup(p_stats, GlobalEnums.Faction.PLAYER)
	
	var enemy = Battler.new()
	enemy.setup(b_stats, GlobalEnums.Faction.ENEMY)
	
	# Test 1: Initial state
	print("\n[TEST 1] Trạng thái khởi đầu:")
	print("Player: Blood = %d, Guilt = %d" % [player.current_blood, player.current_guilt])
	print("Enemy:  Blood = %d, Sin = %d" % [enemy.current_blood, enemy.current_sin])
	assert(player.current_blood == 100 and player.current_guilt == 0, "Initial blood/guilt failed")
	
	# Test 2: Player takes damage -> Blood drops, Guilt rises by exact amount
	print("\n[TEST 2] Player ăn đòn 35 sát thương:")
	var hit1 = player.take_hit(DamageData.new(35, 0))
	print("Player: Blood = %d, Guilt = %d" % [player.current_blood, player.current_guilt])
	print("Hệ số Cuồng Tội (Frenzy): x%.2f" % player.get_guilt_multiplier())
	assert(player.current_blood == 65 and player.current_guilt == 35, "Blood & Guilt vessel failed")
	
	# Test 3: Player self-sacrifice (Blood Cleave setup)
	print("\n[TEST 3] Player tự rạch máu hi sinh 20 Máu:")
	player.sacrifice_blood(20)
	print("Player: Blood = %d, Guilt = %d" % [player.current_blood, player.current_guilt])
	print("Hệ số Cuồng Tội sau hi sinh: x%.2f" % player.get_guilt_multiplier())
	assert(player.current_blood == 45 and player.current_guilt == 55, "Sacrifice blood failed")
	
	# Test 4: Enemy takes attacks and accumulates Sin
	print("\n[TEST 4] Tấn công Quái vật nhồi Sin:")
	enemy.take_hit(DamageData.new(20, 60))
	print("Enemy: Blood = %d, Sin = %d, Stunned = %s" % [enemy.current_blood, enemy.current_sin, enemy.is_stunned])
	assert(enemy.current_sin == 60 and not enemy.is_stunned, "Enemy sin accumulation failed")
	
	# Test 5: Strike again to trigger Stun (Sin >= 100)
	print("\n[TEST 5] Nhồi thêm 50 Sin để kích hoạt CHOÁNG:")
	var hit_stun = enemy.take_hit(DamageData.new(15, 50))
	print("Enemy: Blood = %d, Sin = %d, Stunned = %s" % [enemy.current_blood, enemy.current_sin, enemy.is_stunned])
	assert(enemy.is_stunned, "Enemy should be stunned!")
	assert(hit_stun["caused_stun"], "Result should flag caused_stun")
	
	# Test 6: Verdict Strike on Stunned Enemy
	print("\n[TEST 6] Giáng đòn TRỪNG PHẠT (Verdict) chí mạng:")
	var verdict_dmg = int(80.0 * player.get_guilt_multiplier())
	enemy.take_hit(DamageData.new(verdict_dmg, 0, true, true))
	print("Enemy sau Verdict: Blood = %d, Sin = %d, Stunned = %s" % [enemy.current_blood, enemy.current_sin, enemy.is_stunned])
	assert(enemy.current_sin == 0 and not enemy.is_stunned, "Verdict should clear Sin and Stun")
	
	# Test 7: Atonement (Sám Hối) restores Blood
	print("\n[TEST 7] Kích hoạt SÁM HỐI hồi máu:")
	var healed = player.perform_atonement()
	print("Hồi phục: +%d Máu" % healed)
	print("Player sau Sám Hối: Blood = %d, Guilt = %d" % [player.current_blood, player.current_guilt])
	assert(player.current_blood == 100 and player.current_guilt == 0, "Atonement failed")
	
	print("\n==================================================")
	print("✅ TOÀN BỘ 7 BÀI TEST LOGIC ĐỀU ĐẠT 100%! EXCELLENT! ✅")
	print("==================================================")
	quit()
