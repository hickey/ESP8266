-- Measure temperature, humidity and post data to thingspeak.com
-- 2014 OK1CDJ
-- DHT11 code is from esp8266.com
---Sensor DHT11 is conntected to GPIO0


function Dht:new(l)
  self.pin = l['pin']
  self.temperatureSmoothing = l['temperatureSmoothing']
  self.humiditySmoothing = l['humiditySmoothing']
  self.temperatureHistory = {}
  self.humidityHistory = {}
  self.readTimestamps = {}
  return self
end


function Dht:readSensor()
  --Data stream acquisition timing is critical. There's
  --barely enough speed to work with to make this happen.
  --Pre-allocate vars used in loop.
  self.humidity = 0
  self.humidityDec = 0
  self.temperature = 0
  self.temperatureDec = 0
  self.checksum = 0
  
  -- 40 bits of data
  local bitStream = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  local bitlength=0

  gpio.mode(self.pin, gpio.OUTPUT)
  gpio.write(self.pin, gpio.LOW)
  tmr.delay(20000)
  --Use Markus Gritsch trick to speed up read/write on GPIO
  local gpio_read=gpio.read
  local gpio_write=gpio.write

  gpio.mode(self.pin, gpio.INPUT)

  --bus will always let up eventually, don't bother with timeout
  while (gpio_read(self.pin)==0 ) do end

  local c=0
  while (gpio_read(self.pin)==1 and c<100) do c=c+1 end

  --bus will always let up eventually, don't bother with timeout
  while (gpio_read(self.pin)==0 ) do end

  c=0
  while (gpio_read(self.pin)==1 and c<100) do c=c+1 end

  --acquisition loop
  for j = 1, 40, 1 do
    while (gpio_read(self.pin)==1 and bitlength<10 ) do
      bitlength=bitlength+1
    end
    bitStream[j]=bitlength
    bitlength=0
    --bus will always let up eventually, don't bother with timeout
    while (gpio_read(self.pin)==0) do end
  end

  --DHT data acquired, process.

  for i = 1, 8, 1 do
    if (bitStream[i+0] > 2) then
      self.humidity = self.humidity+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+8] > 2) then
      self.humidityDec = self.humidityDec+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+16] > 2) then
      self.temperature = self.temperature+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+24] > 2) then
      self.temperatureDec = self.temperatureDec+2^(8-i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i+32] > 2) then
      self.checksum = self.checksum+2^(8-i)
    end
  end
  local ChecksumTest=(Humidity+HumidityDec+Temperature+TemperatureDec) % 0xFF
  
  return self.checksum == ChecksumTest
end
