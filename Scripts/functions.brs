Function enableNodeJs()
  r=createobject("rorectangle",0,0,1920,1080)
  aa=createobject("roassociativearray")

  aa.url="http://alexurie.x10host.com/index.html"
  aa.nodejs_enabled=true

  bb=createobject("roassociativearray")
  bb.port=3000
  aa.inspector_server=bb

  h=createobject("rohtmlwidget",r,aa)
  h.show()
End Function

Function networkMessagesReceiver()
  receiver = CreateObject("roDatagramReceiver", 21075)
  mp = CreateObject("roMessagePort")
  receiver.SetPort(mp)
  while true
         event = mp.WaitMessage(0)
         if type(event) = "roDatagramEvent" then
               print "Datagram: "; event
         endif
  end while
End Function

Function sendLOG()

  di = CreateObject("roDeviceInfo")
  print di.GetModel()
  version = di.GetVersion()
  di.GetVersionNumber()
  print di.GetBootVersion(), di.GetBootVersionNumber()
  print di.GetDeviceUptime(), di.GetDeviceBootCount()
  print di.GetDeviceUniqueId()
  print di.HasFeature("ethernet")
  di.HasFeature("hdmi")
  di.HasFeature("sd")
  syslog = CreateObject("roSystemLog")
  syslogArray = syslog.ReadLog()
  syslogJSON = FormatJson(syslog.ReadLog())
  for each key in syslogArray
    syslogString += syslogArray[key]
  end for
  file = CreateObject("roCreateFile", "log.txt")
  file = CreateObject("roAppendFile", "log.txt")
  file.SendLine("Hey")
  url = CreateObject("roUrlTransfer")
  url.SetUrl("http://alexurie.x10host.com/log.txt")
  url.AddHeader("log","hello")
  url.PostFromFile("log.txt")
  url.PutFromFile("log.txt")
  url.PostFromFile("log.txt")
End Function

Function initSystem()
  RebootSystem()
  ShutdownSystem()
  'FormatJson(json As roAssociativeArray, flags As Integer) As String
  'ParseJson(json_string As String) As Object
End Function

Function requestHTTP(file As Object)
  syslog = CreateObject("roSystemLog")
  logValue = syslog.ReadLog()
  logString = ""
  for i = 0 to logValue.Count():
    logString+=logValue[i]
  next
  url = CreateObject("roUrlTransfer")
  url.SetUrl("http://alexurie.x10host.com/received.php")
  url.SetUrl("http://alexurie.x10host.com/log.txt")
  header = { logFile:"Hello"}
  url.AddHeader("log","hello")
  pipe = [{ output_string: True } ]
  response = url.AsyncMethod({ method: "POST", response_pipe: pipe})
  response = url.AsyncGetToFile("info.json")
  response = url.PostFromString("HELLO")
  response = url.getToString()
  print result

  sender.SetDestination("http://alexurie.x10host.com/received.php", 80)
End Function
