#!/usr/bin/env ruby
require 'serialport'
class RNSchrittmotor < SerialPort

  @@debug = false

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

  def emergency_off!
   switch_off!(BOTH)
  end

  def export_settings
    ee = read_eeprom(16)
    %Q(i2c_slave_id = #{ee[0]}
stepper_current = [#{self.class.bytes_to_number(ee[1,2])}, #{self.class.bytes_to_number(ee[3,2])}]
start_current = [#{self.class.bytes_to_number(ee[5,2])}, #{self.class.bytes_to_number(ee[7,2])}]
holding_current = [#{self.class.bytes_to_number(ee[9,2])}, #{self.class.bytes_to_number(ee[11,2])}]
stepping_mode = #{ee[13]}
controller_mode = #{ee[14]}
crc_mode = #{ee[15]}
)
  end

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
   magic_constant = 0x8c # can anyone explain this to me?
   string.each_byte do |byte_value|
     8.times do
        j = 1 & (byte_value ^ crc8)
        crc8 = (crc8 / 2) & 0xff
        byte_value = (byte_value / 2) & 0xff
        if j != 0
          crc8 = crc8 ^ magic_constant
        end
     end
   end
   crc8.chr
  end

  def self.number_to_bytes(number)
    (number & 0xff).chr + (number>>8&0xff).chr
  end

  def self.bytes_to_number(bytes)
    bytes[0]|bytes[1]<<8
  end

  def self.steps_per_sec(num)
    1000 / (num + 1)
  end
end

