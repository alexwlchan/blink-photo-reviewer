function httpPOST(url) {
  var xmlHttp = null;

  xmlHttp = new XMLHttpRequest();
  xmlHttp.open("POST", url, false);
  xmlHttp.send(null);
  return xmlHttp.responseText;
}

function handleKeyDown(event, thisIdentifier, nextIdentifier, prevIdentifier) {
  switch(event.key) {
    case "ArrowLeft":
      window.location = `/?localIdentifier=${prevIdentifier}`;
      break;

    case "ArrowRight":
      window.location = `/?localIdentifier=${nextIdentifier}`;
      break;

    case "1":
      window.location = `/actions?localIdentifier=${thisIdentifier}&action=toggle-approved`;
      break;

    case "2":
      window.location = `/actions?localIdentifier=${thisIdentifier}&action=toggle-rejected`;
      break;

    case "3":
      window.location = `/actions?localIdentifier=${thisIdentifier}&action=toggle-needs-action`;
      break;

    case "f":
      window.location = `/actions?localIdentifier=${thisIdentifier}&action=toggle-favorite`;
      break;

    case "c":
      window.location = `/actions?localIdentifier=${thisIdentifier}&action=toggle-cross-stitch`;
      break;

    case "o":
      httpPOST(`/open?localIdentifier=${thisIdentifier}`);
      break;

    case "u":
      window.location = `/next-unreviewed?before=${thisIdentifier}`;
      break;

    case "?":
      window.location = '/random-unreviewed';
      break;
  }}
