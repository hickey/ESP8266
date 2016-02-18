

function Thinkspeak:new(l)
  self.apiKey = l['apiKey']
  
  -- conection to thingspeak.com
  self.conn=net.createConnection(net.TCP, 0)
  self.conn:on("receive", function(conn, payload) print(payload) end)
  -- api.thingspeak.com 184.106.153.149
  self.conn:connect(80,'184.106.153.149')
  
  return self
end


function Thinkspeak:sendData(l)
  -- build out the URL to be used
  local url = "/update?key=" .. self.apiKey
  for k,v in ipairs(l) do
    url = url..'&'..k..'='..v
  end
  url = url.." HTTP/1.1\r\n"

  self.conn:send("GET "..url)
  self.conn:send("Host: api.thingspeak.com\r\n")
  self.conn:send("Accept: */*\r\n")
  self.conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  self.conn:send("\r\n")
  self.conn:on("sent",function(conn)
                    print("Closing connection")
                    conn:close()
                end)
  self.conn:on("disconnection", function(conn)
                    print("Got disconnection...")
                end)
end