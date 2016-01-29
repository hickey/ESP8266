-- Send to MQTT
mq = mqtt.Client(node.id, 30, '', '')
mq:lwt('/lwt', 'offline', 0, 0)
mq:connect('q.m2m.io', 4483, 0)
data = { "temp"=Temperature.."."..TemperatureDec, "humidity"=Humidity.."."..HumidityDec }
mq:publish('public/wt0f:temp', cjson.encode(data), 0, 0, function(mq) mq:close() end)