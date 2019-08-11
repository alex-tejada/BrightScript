
Sub MainEventHandler()
  MsgPort = CreateObject("roMessagePort")
  receiver = CreateObject("roDatagramReceiver", 2000)
  receiver.SetPort(MsgPort)

  while true
    msg = wait(0, MsgPort)

    if type(msg) = "roDatagramEvent" then
        DatagramManager(msg.GetString())
    endif

  end while
End Sub

Sub PostJSONData(htmlWidget As Object)
  file = CreateObject("roReadFile", "SD:/jsondata.json")
  if file <> invalid then
    json = ReadFileToData("SD:/jsondata.json")
    jsonObject = ParseJson(json)
    htmlWidget.PostJSMessage(jsonObject)
  endif
End Sub

Sub DatagramManager(data As String)
  regex = CreateObject("roRegex","[[]+", "x")
  data = regex.ReplaceAll(data, "")
  list = data.Tokenize("]")
  if list.Count()>0 then
    array = CreateObject("roAssociativeArray")
    dieselRaw1 = list[1]
    dieselRaw2 = list[2]
    dieselRaw3 = list[3]
    dieselRaw4 = list[4]
    magnaRaw1 = list[5]
    magnaRaw2 = list[6]
    magnaRaw3 = list[7]
    magnaRaw4 = list[8]
    premiumRaw1 = list[9]
    premiumRaw2 = list[10]
    premiumRaw3 = list[11]
    premiumRaw4 = list[12]
    if dieselRaw1.Instr("AB")=-1 then
      dieselRaw1 = ConvertHexToString(dieselRaw1)
    endif
    if dieselRaw2.Instr("AB")=-1 then
      dieselRaw2 = ConvertHexToString(dieselRaw2)
    endif
    if dieselRaw3.Instr("AB")=-1 then
      dieselRaw3 = ConvertHexToString(dieselRaw3)
    endif
    if dieselRaw4.Instr("AB")=-1 then
      dieselRaw4 = ConvertHexToString(dieselRaw4)
    endif
    if magnaRaw1.Instr("AB")=-1 then
      magnaRaw1 = ConvertHexToString(magnaRaw1)
    endif
    if magnaRaw2.Instr("AB")=-1 then
      magnaRaw1 = ConvertHexToString(magnaRaw1)
    endif
    if magnaRaw3.Instr("AB")=-1 then
      magnaRaw3 = ConvertHexToString(magnaRaw3)
    endif
    if magnaRaw4.Instr("AB")=-1 then
      magnaRaw4 = ConvertHexToString(magnaRaw4)
    endif
    if premiumRaw1.Instr("AB")=-1 then
      premiumRaw1 = ConvertHexToString(premiumRaw1)
    endif
    if premiumRaw2.Instr("AB")=-1 then
      premiumRaw2 = ConvertHexToString(premiumRaw2)
    endif
    if premiumRaw3.Instr("AB")=-1 then
      premiumRaw3 = ConvertHexToString(premiumRaw3)
    endif
    if premiumRaw4.Instr("AB")=-1 then
      premiumRaw4 = ConvertHexToString(premiumRaw4)
    endif
    array.diesel1 = dieselRaw1 + dieselRaw2
    array.diesel2 = dieselRaw3 + dieselRaw4
    array.magna1 = magnaRaw1 + magnaRaw2
    array.magna2 = magnaRaw3 + magnaRaw4
    array.premium1 = premiumRaw1 + premiumRaw2
    array.premium2 = premiumRaw3 + premiumRaw4
    'WriteDataToFile("SD:/data.json",FormatJson(array))
    generateXML("SD:/data.xml",array)
    UploadData("SD:/data.xml")
  end if
End Sub

Function generateXML(path As String, array As Dynamic)

  root = CreateObject("roXMLElement")
  root.SetName("root")
  newElement=root.AddBodyElement()
  newElement.SetName("diesel1")
  newElement.SetBody(array.diesel1)
  newElement=root.AddBodyElement()
  newElement.SetName("diesel2")
  newElement.SetBody(array.diesel2)
  newElement=root.AddBodyElement()
  newElement.SetName("magna1")
  newElement.SetBody(array.magna1)
  newElement=root.AddBodyElement()
  newElement.SetName("magna2")
  newElement.SetBody(array.magna2)
  newElement=root.AddBodyElement()
  newElement.SetName("premium1")
  newElement.SetBody(array.premium1)
  newElement=root.AddBodyElement()
  newElement.SetName("premium2")
  newElement.SetBody(array.premium2)
  WriteDataToFile(path,root.GenXML(true))
End Function

Function UploadData(path As String)
  TryUpload:
  url = CreateObject("roUrlTransfer")
  url.SetUrl("http://hivisionled.red/tottem/data/receive.php")
  uploadResult = url.PostFromFile(path)
  if uploadResult<1 then
    goto TryUpload
  endif
End Function

Function SetNetworkConfig()
  nc = CreateObject("roNetworkConfiguration", 0)
  nc.SetIP4Address("10.1.1.111")
  nc.SetIP4Netmask("255.255.255.0")
  nc.SetIP4Gateway("10.1.1.1")
  nc.Apply()
End Function

Function ConvertHexToString(data As String) As String
  bytesArray = CreateObject("roByteArray")
  bytesArray.FromHexString(data)
  dataString = bytesArray.ToAsciiString()
  Return dataString
End Function

Function WriteDataToFile(filename As String, data As String)
  file = CreateObject("roCreateFile", filename)
  file.SendLine(data)
  file.Flush()
End Function

Function ReadFileToData(filename As String) As String
  file = CreateObject("roReadFile", filename)
  data = file.ReadLine()
  'WriteDataToFile("SD:/datacopy.xml",data)
  Return data
End Function
