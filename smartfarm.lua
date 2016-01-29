WRITEKEY="19LG5I46KAQ92ZX0"    -- set your thingspeak.com key
-- Pin
gaspin = 8
lightpin=7  
flow_pin = 1
-- Valiable           
ck=0
tmrsent=0
Methane=0
light=0
pulse1=0
count = 0
consumption = 0
-- setup
gpio.mode(gaspin, gpio.OUTPUT)
gpio.mode(lightpin, gpio.OUTPUT)
gpio.write(gaspin, gpio.LOW)
gpio.write(lightpin, gpio.LOW)

function rpm()
     count = count + 1
end

function flowmeter()
     gpio.mode(flow_pin, gpio.INPUT)
     water = (count * 60 / 7.5)
     count = 0  
     gpio.mode(flow_pin, gpio.INT)
     gpio.trig(flow_pin, "up", rpm)
end

function Read_gas_light()
-- read analog from GAS CO  
  gpio.write(gaspin, gpio.HIGH)
  tmr.delay(500)
  Methane = adc.read(0)
  gpio.write(gaspin, gpio.LOW)
-- read analog from light sensor 
  gpio.write(lightpin, gpio.HIGH)
  tmr.delay(500)
  light = adc.read(0)
  gpio.write(lightpin, gpio.LOW)
-- sent data from flow sensor, light sensor and GAS sensor to OLED display
  
  if(wifi.sta.getip()==nil) then  
    display("Re-connect..",light,Methane,water)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid,passwd)
    wifi.sta.connect()
    tmr.alarm(5, 1000, 1, function() 
        if(wifi.sta.getip() == nil)  then 
          display("Waiting IP..",light,Methane,water)
        else 
            tmr.stop(5)
            display(wifi.sta.getip(),light,Methane,water)
            waterPulses=0 
        end
    end)
  else
     display(wifi.sta.getip(),light,Methane,water) 
     waterPulses=0
  end
-- check timer  
  tmrsent=tmrsent+1
  if (tmrsent==31) then
      tmrsent=0
  end
  
end

-- send to https://api.thingspeak.com
function sendTS(humi,temp)

    if ( tmrsent==30) then
            
        print("Sending data to thingspeak.com")
        conn=net.createConnection(net.TCP, 0) 
        conn:on("receive", function(conn, payload) print(payload) end)
        --ip for api.thingspeak.com is 184.106.153.149
        conn:connect(80,'184.106.153.149') 
        conn:send("GET /update?key="..WRITEKEY.."&field4="..Methane.."&field5="..water.."&field7="..light.." HTTP/1.1\r\n")
        conn:send("Host: api.thingspeak.com\r\n") 
        conn:send("Accept: */*\r\n") 
        conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
        conn:send("\r\n")
        conn:on("sent",function(conn)
            print("Closing connection thingspeak.com")
            conn:close()
        end)
        conn:on("disconnection", function(conn)
            print("Got disconnection...")
        end)
            
    end
    
end

tmr.alarm(1,2000,1,function()flowmeter()Read_gas_light()sendTS(humi,temp)end)
--FileView done.
