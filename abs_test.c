void ABS()
{
	[1] sense_wheel_speed();
	if [2,0.5] (slip>slip_max)
	{
		[3] ABS_HOLD (release_delay);
		[4] ABS_DECREASE (release_time);
	}
	else if [5,0.5](slip>slip_min)
	{
		[3] ABS_HOLD (secondary_apply_delay);
		[6] ABS_INCREASE (secondary_increase_time);
	}
	else
	{
		[3] ABS_HOLD (primary_apply_delay);
		[6] ABS_INCREASE (primary_increase_time);
	}
}
