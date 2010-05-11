#!/usr/bin/env ruby
# © 2010 Sascha Teske <sascha.teske@microprojects.de>
require 'serialport'
class RNSchrittmotor < SerialPort

  DEBUG = true

  COMMANDS = [
    [:set_stepper_current,   10, :motor, :mA, :persist],
    [:set_start_current,     11, :motor, :mA, :persist],
    [:set_holding_current,   12, :motor, :mA, :persist],
    [:set_stepping_mode,     13, :mode, :persist],
    [:reset_counter,         14, :motor],
    [:switch_on!,            50, :motor], # are you current settings correct for you stepper?
    [:switch_off!,           51, :motor], # you might wanna be careful if eg. your z-axis is high up it just falls down
    [:set_direction,         52, :motor, :direction],
    [:set_speed,             53, :motor, :speed, :accel],
    [:run!,                  54, :motor],
    [:step!,                 55, :motor, :steps],
    [:read_status,          101, :motor],
    [:read_counter,         102, :motor],
    [:read_i2c_response,    103, :motor],
    [:read_end_switches,    104, :motor],
    [:set_controller_mode,  200, :mode],
    [:set_crc_mode,         201, :onoff],
    [:set_i2c_slave_id,     202, :i2c_id],
    [:reset_eeprom,         203],
    [:read_eeprom,          254, :size],
    [:read_version,         255]
  ]

  COMMANDS.each do |command_name, command_byte, *params|
    class_eval %Q(
      def #{command_name}(#{params.join(',')})
        cmd = #{command_byte}.chr
        #{params.map {|p| [:mA, :steps].include?(p) ? "cmd << number_to_bytes(" + p.to_s + ")\n" : "cmd << " + p.to_s + ".chr\n"}}
        do_it(cmd.ljust(6,0.chr))
      end
    )
  end

  FIRST = 1
  SECOND = 2
  BOTH = 3

  LEFT = 0
  RIGHT = 1

  OFF = 0
  ON = 1

  HALF = 0
  FULL = 1

  FORGET = 0
  PERSIST = 1

  RETURNCODES = { '*' => 'OK', '+' => 'Unknown Command', ',' => 'Wrong CRC', '-' => 'Wrong/Odd Slave ID'}

  def do_it(cmd)
    if DEBUG
      cmd.each_byte do |byte|
        $stdout.print "#{byte} "
      end
      $stdout.print crc8(cmd)
    end
    write('!#' + cmd + crc8(cmd))
    sleep(0.2)
    read
  end

  def crc8(string)
    crc_byte = 0
    string[2..-1].each_byte do |byte| # skip attention-bytes '!#'
      crc_byte = byte ^ crc_byte
    end
    crc_byte.chr
  end

  def number_to_bytes(number)
    (number & 0xff).chr + (number>>8&0xff).chr
  end

end

#rns = RNSchrittmotor.new('/dev/ttyUSB0', 9600)

