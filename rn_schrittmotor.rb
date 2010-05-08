#!/usr/bin/env ruby
# © 2010 Sascha Teske <sascha.teske@microprojects.de>
require 'serialport'
class RNSchrittmotor < SerialPort

  DEBUG = true

  COMMANDS = [
    [:set_stepper_current,   10.chr, :motor, :mA, :persist],
    [:set_start_current,     11.chr, :motor, :mA, :persist],
    [:set_holding_current,   12.chr, :motor, :mA, :persist],
    [:set_stepping_mode,     13.chr, :mode, :persist],
    [:reset_counter,         14.chr, :motor],
    [:switch_on!,            50.chr, :motor],
    [:switch_off!,           51.chr, :motor],
    [:set_direction,         52.chr, :motor, :direction],
    [:set_speed,             53.chr, :motor, :speed, :accel],
    [:run!,                  54.chr, :motor],
    [:step!,                 55.chr, :motor, :steps],
    [:read_status,          101.chr, :motor],
    [:read_counter,         102.chr, :motor],
    [:read_i2c_response,    103.chr, :motor],
    [:read_end_switches,    104.chr, :motor],
    [:set_controller_mode,  200.chr, :mode],
    [:set_crc_mode,         201.chr, :onoff],
    [:set_i2c_slave_id,     202.chr, :i2c_id],
    [:reset_eeprom,         203.chr],
    [:read_eeprom,          254.chr, :size],
    [:read_version,         255.chr]
  ]

  COMMANDS.each do |command_name, command_byte, *params|
    define_method(command_name) do |*params|
      puts params
    end
  end

  FIRST = 1.chr
  SECOND = 2.chr
  BOTH = 3.chr

  LEFT = 0.chr
  RIGHT = 1.chr

  OFF = 0.chr
  ON = 1.chr

  HALF = 0.chr
  FULL = 1.chr

  FORGET = 0.chr
  PERSIST = 1.chr

  RETURNCODES = { '*' => 'OK', '+' => 'Unknown Command', ',' => 'Wrong CRC', '-' => 'Wrong/Odd Slave ID'}

  def do_it(cmd)
    if DEBUG
      string[2..-1].each_byte do |byte|
        $stdout.print "#{byte} "
      end
    end
    write('!#' + cmd + crc8(cmd))
    sleep(0.5)
    read
  end

  def crc8(string)
    crc_byte = 0
    string[2..-1].each_byte do |byte| # skip attention-bytes '!#'
      crc_byte = byte ^ crc_byte
    end
    crc_byte.chr
  end

  #def firmware_version
    #cmd =  255.chr + 0.chr * 5
    #do_it(cmd)
  #end

  #def set_current(stepper, mA, persist = RNSchrittmotor::FORGET)
    #cmd = 10.chr + number_to_bytes(mA) + persist + 0.chr
    #do_it(cmd)
  #end

  #def set_start_current(stepper, mA, persist = RNSchrittmotor::FORGET)
    #cmd = 11.chr + number_to_bytes(mA) + persist + 0.chr
    #do_it(cmd)
  #end

  #def set_sealing_current(stepper, mA, persist = RNSchrittmotor::FORGET)
    #cmd = 12.chr + number_to_bytes(mA) + persist + 0.chr
    #do_it(cmd)
  #end

  #def set_stepping(mode = RNSchrittmotor::HALF, persist = RNSchrittmotor::FORGET)
    #cmd = 13.chr + mode + persist + 0.chr
    #do_it(cmd)
  #end

  #def switch_on!(stepper)
    #cmd = 50.chr + stepper + 0.chr * 4
    #do_it(cmd)
  #end

  #alias :stop! :switch_on!

  #def switch_off!(stepper)
    #cmd = 51.chr + stepper + 0.chr * 4
    #do_it(cmd)
  #end

  #def direction(stepper, dir = RNSchrittmotor::LEFT)
    #cmd = 52.chr + stepper + dir + 0.chr * 3
    #do_it(cmd)
  #end

  #def set_speed_and_acceleration(stepper, steps_per_sec, accel)
    #speed = (1000.0 / (steps_per_sec + 1)).round
    #cmd = 53.chr + stepper + speed.chr + accel.chr + 0.chr * 2
    #do_it(cmd)
  #end

  #def start_spinning!(stepper)
    #cmd = 54.chr + stepper + 0.chr * 4
    #do_it(cmd)
  #end

  #def step!(stepper, steps)
    #cmd = 55.chr + stepper + number_to_bytes(steps) + 0.chr * 3
    #do_it(cmd)
  #end

  #def number_to_bytes(number)
    #(number & 0xff).chr + (number>>8&0xff).chr
  #end

end

#rns = RNSchrittmotor.new('/dev/ttyUSB0', 9600)

