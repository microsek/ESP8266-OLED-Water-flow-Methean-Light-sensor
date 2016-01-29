local sda_pin = 5 -- GPIO14
local scl_pin = 6 -- GPIO12
local oled_addr = 0x3c

i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)
local disp = nil
local disp = u8g.ssd1306_128x64_i2c(oled_addr)

function display(ipa,light,co,water)

  disp:firstPage()
  disp:setFont(u8g.font_6x10)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop()
  
  repeat
    local x=0
    local y=0
    disp:drawRFrame(0, 0, 128, 64, 1)
    disp:drawStr(2, 2, 'Maejo Smart Farm') 
    disp:drawStr(2, 12, "IP: "..ipa) 
    disp:drawStr(2, 22, "Light       = "..light)
    disp:drawStr(2, 32, "GAS Methane = "..co.."ppm")
    disp:drawStr(2, 42, "Water flow  = "..water.."L/h")
  until disp:nextPage() == false

end

function scan_ip()

 -- specify the SSID and PASSWORD for your AP 
  -- specify the SSID and PASSWORD for your AP 
-- ssid   = "AndroidAP" 
--passwd = "phonphirom" 

ssid   = "microsekasus" 
passwd = "qwertyuiop"
--ssid   = "Peterkwifi" 
--passwd = "0859796651" 
display( "set up wifi mode.",'??','??','??')
 wifi.setmode(wifi.STATION)
 wifi.sta.config(ssid,passwd)
 wifi.sta.connect()
 cnt = 0
 tmr.alarm(1, 1000, 1, function() 
    if(wifi.sta.getip() == nil) and (cnt < 20) then 
      display( "Waiting....",'??','??','??','??')
      cnt = cnt + 1 
     else 
      tmr.stop(1)
      if (cnt < 20) then 
       display(wifi.sta.getip(),'??','??','??') 
       dofile("smartfarm.lua")
      else 
--print("can't get ip address")
       display("Can't get IP",'??','??','??') 
      end
     end 
  end)

end

tmr.alarm( 1, 1000, 1, scan_ip )
