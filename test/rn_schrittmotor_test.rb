
set_stepper_current,   10.chr, :motor, :mA, :persist],
    set_start_current,     11.chr, :motor, :mA, :persist],
    set_holding_current,   12.chr, :motor, :mA, :persist],
    set_stepping_mode,     13.chr, :mode, :persist],
    reset_counter,         14.chr, :motor],
    switch_on!,            50.chr, :motor],
    switch_off!,           51.chr, :motor],
    set_direction,         52.chr, :motor, :direction],
    set_speed,             53.chr, :motor, :speed, :accel],
    run!,                  54.chr, :motor],
    step!,                 55.chr, :motor, :steps],
    read_status,          101.chr, :motor],
    read_counter,         102.chr, :motor],
    read_i2c_response,    103.chr, :motor],
    read_end_switches,    104.chr, :motor],
    set_controller_mode,  200.chr, :mode],
    set_crc_mode,         201.chr, :onoff],
    set_i2c_slave_id,     202.chr, :i2c_id],
    reset_eeprom,         203.chr],
    read_eeprom,          254.chr, :size],
    read_version,         255.chr]