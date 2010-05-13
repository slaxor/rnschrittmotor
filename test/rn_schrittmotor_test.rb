# © 2010 Sascha Teske <sascha.teske@microprojects.de>
require 'rubygems'
require 'test/unit'
require 'mocha'
require 'stringio'
require File.join([File.expand_path(File.dirname(__FILE__)), '..', 'rn_schrittmotor'])

class RNSchrittmotorTest <Test::Unit::TestCase

  def setup
    @stepper = RNSchrittmotor.new('/dev/ttyUSB0', 9600)
  end

  def test_crc8
    assert_equal "\x56",  RNSchrittmotor.crc8("\xff\x00\x00\x00\x00\x00")
    assert_equal "\x0e",  RNSchrittmotor.crc8("\xfe\x0f\x00\x00\x00\x00")
  end

  def test_do_it
    @stepper.expects(:write).with("!#\xff\x00\x00\x00\x00\x00\x56")
    @stepper.expects(:read)
    @stepper.do_it("\xff\x00\x00\x00\x00\x00")
  end

  #eeprom_bytes
  #0 I2C Slave ID
  #1 Motorstrom in mA Motor 1 Low-Byte
  #2 Motorstrom in mA Motor 1 High-Byte
  #3 Motorstrom in mA Motor 2 Low-Byte
  #4 Motorstrom in mA Motor 2 High-Byte
  #5 Haltestrom in mA Motor 1 Low-Byte
  #6 Haltestrom in mA Motor 1 High-Byte
  #7 Haltestrom in mA Motor 2 Low-Byte
  #8 Haltestrom in mA Motor 2 High-Byte
  #9 Anlaufstrom in mA Motor 1 Low-Byte
  #10 Anlaufstrom in mA Motor 1 High-Byte
  #11 Anlaufstrom in mA Motor 2 Low-Byte
  #12 Anlaufstrom in mA Motor 2 High-Byte
  #13 Schrittmotormodus 0=Vollschritt 1=Halbschritt
  #14 Schnittstellenmodus 1=Intelligent 2=Takt
  #15 CRC Mode 1=aktiv 0=aus

  def test_export_settings
    @stepper.expects(:do_it).with("\xfe\x10\x00\x00\x00\x00").returns("\x42\x00\x04\x00\x04\x00\x05\x00\x05\xfa\x00\xfa\x00\x01\x02\x00")
    assert_equal %Q(i2c_slave_id = 66
stepper_current = [1024, 1024]
start_current = [1280, 1280]
holding_current = [250, 250]
stepping_mode = 1
controller_mode = 2
crc_mode = 0
), @stepper.export_settings
  end

  def test_number_to_bytes
    assert_equal "\x04\x0c", RNSchrittmotor.number_to_bytes(3076)
  end

  def test_bytes_to_number
    assert_equal 32515, RNSchrittmotor.bytes_to_number("\x03\x7f")
  end

  def test_read_counter
    @stepper.expects(:do_it).with("f\001\000\000\000\000").returns("\xff\xff")
    assert_equal "\xff\xff", @stepper.read_counter(RNSchrittmotor::FIRST)
  end

  def test_read_eeprom
    @stepper.expects(:do_it).with("\xfe\x20\000\000\000\000").returns("\xff" * 32)
    assert_equal "\xff" * 32, @stepper.read_eeprom(32)
  end

  def test_read_end_switches
    @stepper.expects(:do_it).with("h\000\000\000\000\000").returns("\x0f")
    assert_equal "\x0f", @stepper.read_end_switches
  end

  def test_read_i2c_response
    @stepper.expects(:do_it).with("g\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.read_i2c_response
  end

  def test_read_status
    @stepper.expects(:do_it).with("e\001\000\000\000\000").returns("\x00")
    assert_equal "\x00", @stepper.read_status(RNSchrittmotor::FIRST)
  end

  def test_read_version
    @stepper.expects(:do_it).with("\xff\000\000\000\000\000").returns("blah version string")
    assert_equal "blah version string", @stepper.read_version
  end

  def test_reset_counter
    @stepper.expects(:do_it).with("\016\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.reset_counter(RNSchrittmotor::FIRST)
  end

  def test_reset_eeprom
    @stepper.expects(:do_it).with("\313\313\000\000\000\000").returns("*")
    assert_equal "*", @stepper.reset_eeprom(203)
  end

  def test_run!
    @stepper.expects(:do_it).with("6\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.run!(RNSchrittmotor::FIRST)
  end

  def test_set_controller_mode
    @stepper.expects(:do_it).with("\310\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::SERIAL)
    @stepper.expects(:do_it).with("\310\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::I2C)
    @stepper.expects(:do_it).with("\310\002\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_controller_mode(RNSchrittmotor::PULSE)
  end

  def test_set_crc_mode
    @stepper.expects(:do_it).with("\311\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_crc_mode(RNSchrittmotor::CRCON)
    @stepper.expects(:do_it).with("\311\000\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_crc_mode(RNSchrittmotor::CRCOFF)
  end

  def test_set_direction
    @stepper.expects(:do_it).with("4\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::LEFT)
    @stepper.expects(:do_it).with("4\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::CCW)
    @stepper.expects(:do_it).with("4\001\001\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::RIGHT)
    @stepper.expects(:do_it).with("4\001\001\000\000\000").returns("*")
    assert_equal "*", @stepper.set_direction(RNSchrittmotor::FIRST, RNSchrittmotor::CW)
  end

  def test_set_i2c_slave_id
    @stepper.expects(:do_it).with("\312\026\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_i2c_slave_id(22)
  end

  def test_steps_per_sec
     assert_equal 0, RNSchrittmotor.steps_per_sec(1000)
     assert_equal 1, RNSchrittmotor.steps_per_sec(500)
     assert_equal 250, RNSchrittmotor.steps_per_sec(3)
  end

  def test_set_speed
    @stepper.expects(:do_it).with("5\001\377\377\000\000").returns("*")
    assert_equal "*", @stepper.set_speed(RNSchrittmotor::FIRST, 255, 255)
    @stepper.expects(:do_it).with("5\001\004\005\000\000").returns("*")
    assert_equal "*", @stepper.set_speed(RNSchrittmotor::FIRST, RNSchrittmotor.steps_per_sec(200), 5)
  end

  def test_set_start_current
    @stepper.expects(:do_it).with("\x0b\003\x08\x07\x00\x00").returns("*")
    assert_equal "*", @stepper.set_start_current(RNSchrittmotor::BOTH, 1800, RNSchrittmotor::FORGET)
  end

  def test_set_stepper_current
    @stepper.expects(:do_it).with("\x0a\x01\xe8\x03\x00\x00").returns("*")
    assert_equal "*", @stepper.set_stepper_current(RNSchrittmotor::FIRST, 1000, RNSchrittmotor::FORGET)
  end

  def test_set_holding_current
    @stepper.expects(:do_it).with("\x0c\x01\x64\000\000\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::FIRST, 100, RNSchrittmotor::FORGET)
    @stepper.expects(:do_it).with("\x0c\002\x64\000\001\000").returns("*")
    assert_equal "*", @stepper.set_holding_current(RNSchrittmotor::SECOND, 100, RNSchrittmotor::PERSIST)
  end

  def test_set_stepping_mode
    @stepper.expects(:do_it).with("\r\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.set_stepping_mode(RNSchrittmotor::FULL, RNSchrittmotor::FORGET)
    @stepper.expects(:do_it).with("\r\000\001\000\000\000").returns("*")
    assert_equal "*", @stepper.set_stepping_mode(RNSchrittmotor::HALF, RNSchrittmotor::PERSIST)
  end

  def test_step!
    @stepper.expects(:do_it).with("7\001\270\v\000\000").returns("*")
    assert_equal "*", @stepper.step!(RNSchrittmotor::FIRST, 3000)
  end

  def test_switch_off!
    @stepper.expects(:do_it).with("3\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.switch_off!(RNSchrittmotor::FIRST)
  end

  def test_switch_on!
    @stepper.expects(:do_it).with("2\001\000\000\000\000").returns("*")
    assert_equal "*", @stepper.switch_on!(RNSchrittmotor::FIRST)
  end

  def test_emergency_off!
    @stepper.expects(:do_it).with("3\003\000\000\000\000").returns("*")
    assert_equal "*", @stepper.emergency_off!
  end
end

