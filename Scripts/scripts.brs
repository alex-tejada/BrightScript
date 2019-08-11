LIBRARY "v30/bslCore.brs"

Sub MainEventHandler()

  MsgPort = CreateObject("roMessagePort")
  receiver = CreateObject("roDatagramReceiver", 139)
  receiver.SetPort(MsgPort)

  while true

    msg = wait(0, MsgPort)

    if type(msg) = "roDatagramEvent" then
      'list = event.GetString().Tokenize("&")
      'For i=0 To list.Count() Step 1
        DatagramManager(msg.GetString())
      'End For
    endif
    if type(msg) = "roSqliteEvent" then

    endif
    if type(msg) = "roHttpEvent" then

    endif
  end while

End Sub

Sub DatagramManager(data As String)
  jsonObject = ParseJson(data)
  messageid = jsonObject.messageid
  if messageid.Instr("C")<>-1 then

  else if messageid.Instr("D")<>-1 then

  else if messageid.Instr("I")<>-1 then
    InfoFunctions(jsonObject)
  else if messageid.Instr("M")<>-1 then
    MediaFunctions(jsonObject)
  else if messageid.Instr("S")<>-1 then

  else

  endif
End Sub

Function InfoFunctions (jsonObject As Dynamic)
  if jsonObject.messageid = "I1U" then
    SendUnitData()
  else if jsonObject.messageid = "I2U" then
    GetAndSavaFile(jsonObject.url,jsonObject.filename)
  endif
End Function

Function MediaFunctions (jsonObject As Dynamic)

  if jsonObject.messageid = "M1U" then
      takeScreenshot()
      UploadScreenshot()
      'uploadMessage = ""
      'if UploadScreenshot() = 0 then
      '   uploadMessage = "0"
      'else
      ''   uploadMessage = "1"
      'endif
      'array = CreateObject("roAssociativeArray")
      'di = CreateObject("roDeviceInfo")
      'array.messageid = "M1U"
      'array.uploadresult = uploadMessage
      'array.unitid = di.GetDeviceUniqueId()
      'jsonString = FormatJson(array)
      'UDPSend(jsonString)
  else if jsonObject.messageid = "M2U" then
    setImagePlayer(jsonObject.displaytext)
  endif
End Function

Function ServerFunctions (jsonObject As Dynamic)
  if jsonObject.messageid = "S1U" then

  endif
End Function

Function GetAndSavaFile(url As String,filename As String)
  urlTrans = CreateObject("roUrlTransfer")
  'urlTrans.SetTimeout(10000)
  urlTrans.SetUrl(url+filename)
  response = urlTrans.GetToFile("SD:/"+filename)
End Function

Function SendUnitData()
  file = CreateObject("roReadFile", "SD:/server.json")
  if file <> invalid then
    data = ReadFileToData("SD:/server.json")
    json = ParseJson(data)
    address = json.server
    di = CreateObject("roDeviceInfo")
    array = CreateObject("roAssociativeArray")
    array.messageid = "I1U"
    array.unitid = di.GetDeviceUniqueId()
    array.model = di.GetModel()
    array.firmware = di.GetVersion()
    UDPSend(FormatJson(array), address)
  endif
End Function

Function takeScreenshot()
  videoMode = CreateObject("roVideoMode")
  aa = {}
  aa.filename = "SD:/screenshots/screenshot.jpg"
  aa.Width = videoMode.GetResX()
  aa.Height = videoMode.GetResY()
  aa.filetype = "JPEG"
  aa.quality = 50
  aa.Async = 0
  ok = videoMode.Screenshot(aa)
End Function

Function UploadScreenshot() As Integer
  directory = "SD:/screenshots/"
  result = CreateDirectory(directory)
  list = CreateObject("roList")
  list = ListDir(directory)
  uploadResult = 0
  if list.Count() > 0 then
    imageName = list.Peek()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://hivisionled.red/repo-hvl-cms/screenshots/saveScreenshot.php?unitid="+imageName)
    uploadResult = url.PostFromFile(directory+imageName)
  endif
  'bytesArray = CreateObject("roByteArray")
  'readBool = bytesArray.ReadFile(directory+imageName)
  'if readBool then
  'bytesArray.WriteFile("SD:/readBytes.txt")
End Function

Function UDPSend(message As String, address As String)
    sender = CreateObject("roDatagramSender")
    sender.SetDestination(address, 139)
    sender.Send(message)
End Function

Function LoadStartVideo()
  v = CreateObject("roVideoPlayer")
  v.SetViewMode(1) '1920x240'

  aa=CreateObject("roAssociativeArray")
  aa.FadeInLength=2000
  aa.FadeOutLength=2000
  aa.filename = "SD:/video/MarqOferta-AlaskaLTVerano.mp4"
  v.PlayFile(aa)

End Function

Function serverRequest()
  url = CreateObject("roUrlTransfer")
  mp = CreateObject("roMessagePort")
  url.SetPort(mp)
  url.AddHeader("header","hello")
  url.SetUrl("http://alexurie.x10host.com/received.php")
  url.AsyncGetToString()
  while true
         event = mp.WaitMessage(0)
         if type(event) = "roUrlEvent" then
            if event.GetString() = "hello" then
              ShutdownSystem()
            endif
         endif
  end while
End Function

Function serverAsyncMethod()
  url = CreateObject("roUrlTransfer")
  mp = CreateObject("roMessagePort")
  url.SetPort(mp)
  url.SetUrl("http://alexurie.x10host.com/received.php?header=hello")
  aa = {}
  aa.method = "POST"
  aa.response_body_string = true
  url.AsyncMethod(aa)
End Function

Function allowTelnet()
  'TELNET
  reg = CreateObject("roRegistrySection", "networking")
  reg.write("telnet","8085")
  reg.flush()
End Function

Function allowHTMLRemote()

  msgPort = CreateObject("roMessagePort")

  r = CreateObject("roRectangle", 0, 0, 1920, 1080)

  config = createobject("roassociativearray")
  config.nodejs_enabled = true
  config.url = "http://alexurie.x10host.com/index.html"

  bb=createobject("roassociativearray")
  bb.port=3000
  config.inspector_server=bb

  h = CreateObject("roHtmlWidget", r, config)
  h.SetPort(msgPort)
  sleep(10000)
  h.Show()

  while true
      msg = wait(0, msgPort)
      print "type(msg)=";type(msg)
      if type(msg) = "roHtmlWidgetEvent" then
          eventData = msg.GetData()
          if type(eventData) = "roAssociativeArray" and type(eventData.reason) = "roString" then
              print "reason = ";eventData.reason
              if eventData.reason = "load-error" then
                  print "message = ";eventData.message
              endif
          endif
      endif
  end while
End Function

Sub SettingDatabase() As Boolean
  db = CreateObject("roSqliteDatabase")
  path = "SD:/local.db"
  openResult = db.Open(path)
  if NOT openResult then
      db.Create(path)
      stmt = db.CreateStatement("CREATE TABLE server (id int PRIMARY KEY, address text);CREATE TABLE userdata (id int PRIMARY KEY, username text, clientnumber text);")
      stmtResult = stmt.Run()
      'data = ReadFileToData("SD:/server.json")
      return False
  endif
  return True
End Sub

Function WriteDataToFile(filename As String, data As String)
  file = CreateObject("roCreateFile", filename)
  file.SendLine(data)
  file.Flush()
End Function

Function AppendDataToFile(filename As String, data As String)
  file = CreateObject("roAppendFile", filename)
  file.SendLine(data)
  file.Flush()
End Function

Function ReadFileToData(filename As String) As String
  file = CreateObject("roReadFile", filename)
  data = file.ReadLine()
  Return data
End Function

Function getJSONContent()
  jsonString = setJSONContent()
  jsonObject = ParseJson(jsonString)
  For Each content In jsonObject.contents
    title = content.title
    url = content.url
  End For
  WriteDataToFile("SD:/dataJSON.json",jsonString)
End Function

Function setJSONContent() As String
  arrayList = CreateObject("roAssociativeArray")
  array = CreateObject("roArray", 2, true)
  contents = { url:"http", title:"video"}
  array.Push(contents)
  array.Push(contents)
  arrayList.contents = array
  Return FormatJson(arrayList)
End Function

Function generateXML()
  root = CreateObject("roXMLElement")
  root.SetName("root")
  root.AddAttribute("ScheduleContent","1")
  newElement=root.AddBodyElement()
  newElement.SetName("Content")
  newElement.AddAttribute("name","videowall")
  newElement.SetBody("url")
  interiorNewElement = newElement.AddBodyElement()
  interiorNewElement.SetName("Schedule")
  interiorNewElement.AddAttribute("date","10-10-2018")
  interiorNewElement.AddAttribute("hour","15:00")
  interiorNewElement.SetBody("ID1213")
  root.AddElementWithBody("Content","url")
  newElement=root.AddBodyElement()
  newElement.SetName("Content")
  newElement.AddAttribute("name","static-image")
  newElement.SetBody("url")
  WriteDataToFile("SD:/data.xml",root.GenXML(true))
End Function

Function getXMLContent()
  data = ReadFileToData("SD:/data.xml")
  root = CreateObject("roXMLElement")
  root.Parse(data)
  childs = root.GetChildElements()
  for each element in childs
    WriteDataToFile("SD:/dataresult.txt","Element: "+element.GetName())
    if element.GetName() = "Content" then
      newChilds = element.GetChildElements()
      for each element in newChilds
        AppendDataToFile("SD:/dataresult.txt","Element: "+element.GetName())
      end for
    endif
  end for
  'WriteDataToFile("SD:/datacopy.xml",root.GenXML(true))
End Function

Sub setImagePlayer(displayText As String)
  imagePath = "SD:/green.bmp"
  width = 1920
  height = 1080
  r = CreateObject("roRectangle", 0, 0, width, height)
  array = CreateObject("roAssociativeArray")
  array.LineCount = 6
  array.TextMode = 2
  array.Alignment = 1
  'imagePlayer = CreateObject("roImagePlayer")
  'imagePlayer.SetRectangle(r)
  'imagePlayer.DisplayFile(imagePath)
  'imagePlayer.Show()
  textWidget = CreateObject("roTextWidget", r, 12, 2,array)
  textWidget.SetBackgroundBitmap(imagePath, True)
  textWidget.SetForegroundColor(HexToInteger("FFFFFF"))
  textWidget.SetBackgroundColor(0)
  textWidget.PushString(displayText)
  textWidget.Show()
  'imageWidget = CreateObject("roImageWidget", r)
  'imageWidget.DisplayFile(imagePath)
  'imageWidget.Show()
  'videoPlayer = CreateObject("roVideoPlayer")
  'videoPlayer.SetRectangle(r)
  'videoPlayer.PlayStaticImage(imagePath)
  'videoPlayer.Show()
  'textWidget.Raise()
  'meta = CreateObject("roAssociativeArray")
  'meta.AddReplace("CharWidth", 200)
  'meta.AddReplace("CharLength", 120)
  'meta.AddReplace("TextColor", HexToInteger("FFFFFF"))
  'meta.AddReplace("BackgroundColor", HexToInteger("000000"))
  'vm = CreateObject("roVideoMode")
  'tf = CreateObject("roTextField", vm.GetSafeX()+(width/4), vm.GetSafeX()+(height/4), 50, 20, meta)
  'print #tf, texttodisplay
  Sleep(10000)
End Sub
