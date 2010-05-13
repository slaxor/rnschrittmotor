#!/usr/bin/env ruby
# © 2010 Sascha Teske <sascha.teske@microprojects.de>
require 'serialport'
class RNSchrittmotor < SerialPort

  @@debug = true

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
    [:read_i2c_response,    103],
    [:read_end_switches,    104],
    [:set_controller_mode,  200, :mode],
    [:set_crc_mode,         201, :onoff],
    [:set_i2c_slave_id,     202, :i2c_id],
    [:reset_eeprom,         203, :confirm], # totally braindead
    [:read_eeprom,          254, :size],
    [:read_version,         255]
  ]

  COMMANDS.each do |command_name, command_byte, *params|
    class_eval %Q(
      def #{command_name}(#{params.join(',')})
        cmd = #{command_byte}.chr
        #{params.map {|p| [:mA, :steps].include?(p) ? "cmd << self.class.number_to_bytes(" + p.to_s + ")\n" : "cmd << " + p.to_s + ".chr\n"}}
        do_it(cmd.ljust(6,0.chr))
      end
    )
  end

  SERIAL = I2C = 0
  PULSE = 2

  FIRST = 1
  SECOND = 2
  BOTH = 3

  CCW = LEFT = 0
  CW = RIGHT = 1

  CRCOFF = 0
  CRCON = 1

  HALF = 0
  FULL = 1

  FORGET = 0
  PERSIST = 1

  RETURNCODES = { '*' => 'OK', '+' => 'Unknown Command', ',' => 'Wrong CRC', '-' => 'Wrong/Odd Slave ID'}

  def do_it(cmd)
    if @@debug
      cmd.each_byte do |byte|
        $stdout.print "#{byte} "
      end
      $stdout.print "[#{self.class.crc8(cmd)[0]}]"
    end
    write('!#' + cmd + self.class.crc8(cmd))
    sleep(0.2)
    read
  end

  def self.crc8(string)
    crc8 = 0
    string.each_byte do |byte|
      8.times do
        byte_xor_crc8 = (byte ^ crc8)
        crc8 = crc8 / 2
        if byte_xor_crc8.odd?
          crc8 = crc8 ^ 0x8c # no idea why it is 0x8c but the example said so
        end
      end
    end
    crc8.chr
  end

  def self.number_to_bytes(number)
    (number & 0xff).chr + (number>>8&0xff).chr
  end

  def self.steps_per_sec(num)
    1000 / (num + 1)
  end
end

