if (keyboard_check(vk_left)) {
	angle -= rotate_speed;
}

if (keyboard_check(vk_right)) {
	angle += rotate_speed;
}

if (keyboard_check(vk_down)) {
	distance -= rotate_speed;
}

if (keyboard_check(vk_up)) {
	distance += rotate_speed;
}