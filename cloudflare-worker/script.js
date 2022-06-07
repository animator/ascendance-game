addEventListener("fetch", event => {
  event.respondWith(handleRequest(event.request))
})

class UrlParams {
  constructor(search) {
    this.qs = search;
    this.params = {};
    this.parseQuerstring();
  }
  parseQuerstring() {
    this.qs.split('&').reduce((a, b) => {
      let [key, val] = b.split('=');
      a[key] = val;
      return a;
    }, this.params);
  }
  get(key) {
    return this.params[key];
  }
  has(key) {
    return key in this.params;
  }
}

async function handleRequest(request) {

  var queryString = request.url.split('?')[1];
  const params = new UrlParams(queryString);

  var ques = null;
  var ans = null;

  if (params.has("q")) {
    var qId = params.get("q");
    ques = await DB.get("q" + qId);
    ans = await DB.get("a" + qId);
  }

  //if (value === null) {
  //  return new Response("Value not found", { status: 404 });
  //}

  const data = {
    q: ques,
    a: ans,
  };

  const json = JSON.stringify(data, null, 2);

  return new Response(json, {
    headers: { 'content-type': 'application/json;charset=UTF-8', "Access-Control-Allow-Origin": "*" },
  });
}

