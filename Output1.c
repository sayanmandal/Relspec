void ABS(int x , int a , float b)
 {
int  b;
int  y;
	sense_wheel_speed() ;
	sense_vehicle_speed() ;
	calculate(slip) ;
 if (slip > slip_max)
 {
	calculate(release_delayighf) ;
	ABS_HOLD(release_delay) ;
	calculate(release_time) ;
	ABS_DECREASE(release_time) ;
 
} else  if (slip >= slip_min)
 {
	calculate_secondary_apply_delay() ;
	ABS_HOLD(secondary_apply_delay) ;
	calculate_secondary_increase_time() ;
	ABS_INCREASE(secondary_increase_time) ;
 
} else  {
	calculate(primary_apply_delay) ;
	ABS_HOLD(primary_apply_delay) ;
	calculate(primary_increase_time) ;
	ABS_INCREASE(primary_increase_time) ;
 
} 
}