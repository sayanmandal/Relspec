void ABS()
{
	[1] sense_wheel_speed();
	[2] sense_vehicle_speed();
	[3] calculate(slip);
	if [3,0.5] (slip>slip_max)
	{
		[3] calculate(release_delay);
		[4] ABS_HOLD (release_delay);
		[3] calculate(release_time);
		[5] ABS_DECREASE (release_time);
	}
	else if [3,0.5](slip >slip_min)
	{
		[3] calculate_secondary_apply_delay();
		[4] ABS_HOLD (secondary_apply_delay);
		[3] calculate_secondary_increase_time();
		[6] ABS_INCREASE (secondary_increase_time);
	}
	else
	{
		[3] calculate(primary_apply_delay);
		[4] ABS_HOLD (primary_apply_delay);
		[3] calculate(primary_increase_time);
		[6] ABS_INCREASE (primary_increase_time);
	}
}
