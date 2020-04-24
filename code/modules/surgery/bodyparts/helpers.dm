
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		if(L.body_zone == zone)
			return L

/mob/living/carbon/has_hand_for_held_index(i)
	if(i)
		var/obj/item/bodypart/L = hand_bodyparts[i]
		if(L && !L.disabled)
			return L
	return FALSE

/mob/proc/has_left_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_left_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(L.held_index % 2)
			if(!check_disabled || !L.disabled)
				return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_left_hand()
	return TRUE


/mob/proc/has_right_hand(check_disabled = TRUE)
	return TRUE

/mob/living/carbon/has_right_hand(check_disabled = TRUE)
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(!(L.held_index % 2))
			if(!check_disabled || !L.disabled)
				return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_right_hand()
	return TRUE

/mob/proc/has_left_leg()
	return TRUE

/mob/living/carbon/has_left_leg()
	var/obj/item/bodypart/l_leg = get_bodypart(BODY_ZONE_L_LEG)
	if(l_leg)
		return TRUE
	else
		return FALSE

/mob/proc/has_right_leg()
	return TRUE

/mob/living/carbon/has_right_leg()
	var/obj/item/bodypart/r_leg = get_bodypart(BODY_ZONE_R_LEG)
	if(r_leg)
		return TRUE
	else
		return FALSE

//Limb numbers
/mob/proc/get_num_arms(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_arms(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			if(!check_disabled || !affecting.disabled)
				.++
		if(affecting.body_part == ARM_LEFT)
			if(!check_disabled || !affecting.disabled)
				.++


//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
	return 0

/mob/living/carbon/alien/larva/get_arm_ignore()
	return 1 //so we can still handcuff larvas.


/mob/proc/get_num_legs(check_disabled = TRUE)
	return 2

/mob/living/carbon/get_num_legs(check_disabled = TRUE)
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			if(!check_disabled || !affecting.disabled)
				.++
		if(affecting.body_part == LEG_LEFT)
			if(!check_disabled || !affecting.disabled)
				.++

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return FALSE

/mob/living/carbon/get_leg_ignore()
	if(movement_type & (FLYING|FLOATING))
		return TRUE
	return FALSE

/mob/living/carbon/alien/larva/get_leg_ignore()
	return TRUE

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/carbon/alien/larva/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/proc/get_disabled_limbs()
	return list()

/mob/living/carbon/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting && affecting.disabled)
			disabled += zone
	return disabled

/mob/living/carbon/alien/larva/get_disabled_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	var/list/disabled = list()
	for(var/zone in full)
		var/obj/item/bodypart/affecting = get_bodypart(zone)
		if(affecting && affecting.disabled)
			disabled += zone
	return disabled

//Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.forceMove(T)
			I.unembedded()

	clear_alert("embeddedobject")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "embedded")

/mob/living/carbon/proc/has_embedded_objects()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			return 1


//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
			L.body_markings = null
	. = L

/mob/living/carbon/monkey/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/monkey()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/monkey()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/monkey()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/monkey()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/monkey()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/monkey()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/larva/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/larva()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/larva()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/humanoid/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/alien()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/alien()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/alien()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/alien()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/alien()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/alien()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"
		if("orange")
			. = "ffc905"

/mob/living/carbon/proc/Digitigrade_Leg_Swap(swap_back)
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		if((O.body_part == LEG_LEFT || O.body_part == LEG_RIGHT) && ((!O.use_digitigrade && !swap_back) || (O.use_digitigrade && swap_back)))
			O.use_digitigrade = swap_back ? NOT_DIGITIGRADE : FULL_DIGITIGRADE
			O.update_limb(FALSE, src)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform)
			H.update_inv_w_uniform()
		if(H.shoes)
			H.update_inv_shoes()
		if(H.wear_suit)
			H.update_inv_wear_suit()

/mob/living/carbon/proc/get_body_parts_flags()
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		switch(L.body_part)
			if(CHEST)
				. |= GROIN
			if(LEG_LEFT)
				. |= FOOT_LEFT
			if(LEG_RIGHT)
				. |= FOOT_RIGHT
			if(ARM_LEFT)
				. |= HAND_LEFT
			if(ARM_RIGHT)
				. |= HAND_RIGHT
		. |= L.body_part