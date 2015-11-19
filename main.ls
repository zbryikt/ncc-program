require! <[fs cheerio request bluebird]>


rule = /lremark\[\d+\]='(.+)';$/
#lines = (fs.read-file-sync \data .toString!split \\n).map(->rule.exec(it.trim!)).filter(->it).map(->it.1)
#lines = lines.map(-> it.split('<br>'))


# 資料結構:
#   0 - 節目名     #   1 - 製作公司 #   2 - 電視台
#   3 - 播放地區   #   4 - 播放星期 #   5 - 播放時段起
#   6 - 播放時段迄 #   7 - 節目類別 #   8 - 製作方式
#   9 - 播放種類   #  10 - 電視級別 #  11 - 語言
#  12 - 異動資訊   #  13 - 日期

parser = (date, data) ->
  ret = []
  lines = (data.split \\n).map(->rule.exec(it.trim!)).filter(->it).map(->it.1)
  lines = lines.map(-> it.split('<br>'))
  for line in lines =>
    line.4 = line.4.replace(/播放地區:?/,"")
    line.5 = line.5.replace(/播放星期:?/,"")
    line.6 = line.6.replace(/播放時段:?/,"").split(" 至 ").map(->it.trim!)
    line.7 = line.7.replace(/節目類別:?/,"")
    line.8 = line.8.replace(/製作方式:?/,"")
    line.9 = line.9.replace(/播放種類:?/,"")
    line.10 = line.10.replace(/電視級別:?/,"")
    line.11 = line.11.replace(/語言:?/,"")
    seg = line.splice 6, 1
    line.splice.apply line, ([6,0] ++ seg.0)
    line = line.filter(->it).map(->it.trim!)
    line.push date
    ret.push line
  ret

generate-url = (start="1041101", end="1041101") -> 
  "http://nccstat.ncc.gov.tw/ncc/stnccpr.jsp?sys=1&datef=#start&datet=#end&timef=0" +
  "&timet=24&f3=1&w0=1&w1=1&w2=1&w3=1&w4=1&w5=1&w6=1&k1=1&k2=2&k3=3&k4=4&i1=1&i2=2" +
  "&i3=3&i4=4&i5=5&i6=6&i7=10&s1=1&s2=2&s3=3&aplid=&freq=&cname=&freqnm=&pgmnm=" +
  "&ldrpsn=&rdm=qr6AnejV"

fetch-url = (date="1041101") -> new bluebird (res, rej) ->
  url = generate-url date
  (e,r,b) <- request {
    url
    method: \GET
    headers: do
      User-Agent: 
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) " +
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36"
  }, _
  if e => return rej!
  ret = parser date, b
  res ret

date-format = -> "#{it.getYear! - 11}-#{pad(it.getMonth! + 1)}-#{pad(it.getDate!)}"

pad = -> if it < 10 => "0#it" else "#it"
fetch-url!then (ret) ->
  fs.write-file-sync "output.json", JSON.stringify(ret)

fetch-chain = (cur, max, payload = [], single-file) ->
  if cur > max => 
    console.log "finished."
    if single-file => fs.write-file-sync "output.json", JSON.stringify(payload)
    return
  console.log "fetching #{date-format(new Date(cur))} ..."
  cur = new Date(cur)
  next = cur.getTime! + 86400 * 1000
  date = "#{(cur.getYear! - 11)}#{pad(cur.getMonth! + 1)}#{pad(cur.getDate!)}"
  (ret) <- fetch-url date .then
  if !single-file =>
    if !fs.exists-sync \data => fs.mkdir \data
    fs.write-file-sync "data/#{date-format(new Date(cur))}.json", JSON.stringify(ret)
  else payload ++= ret
  fetch-chain next, max, payload

fetch-range = (start, end, single-file = true) ->
  console.log "fetching program range from #{date-format(start)} to #{date-format(end)} ..."
  [start, end] = [start, end].map(->it.get-time!)
  fetch-chain(start, end, [], single-file)

fetch-range new Date("2015/08/01"), new Date("2015/11/09"), false

